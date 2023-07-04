<#
    .SYNOPSIS
        Grab upstream switch information from LLDP and post to Hudu
    .DESCRIPTION
        Polls network adapters for an active network connection. On success, return the IP address of the upstream switch, 
        the Port Identifier (typically Port Number) and switch model
    .NOTES
        Version:  1.0
        Author:  Alden Wilson
        Creation Date:  07-03-2023
        Last Update:  07-04-2023
        
        * The error handling on line 34 must be modified to fit your deployment tool (RMM or otherwise)
        * Modify the $filepath variable on line 100 to fit company preferences.
        
        TODO: Create helper function to tie into documentation system to properly correlate data with related devices (Endpoints and Switches)


#>

<############
  Functions
############>
function Test-Administrator {  
    [OutputType([bool])]
    param()
    process {
        [Security.Principal.WindowsPrincipal]$user = [Security.Principal.WindowsIdentity]::GetCurrent();
        return $user.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator);
    }
}

if (-not (Test-Administrator)) {
    # Write proper error handling for your RMM
    Write-Host "This script must be ran as Administrator";
    exit 1;
}

$ErrorActionPreference = "Stop";

if (-not (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Prompt the user to elevate the script
    $arguments = "& '" + $myInvocation.MyCommand.Definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    exit
}


Function Get-ValidNetworkInterface {

    $WmiParams = @{
        Namespace = 'root\CIMV2'
        Query     = 'SELECT * FROM Win32_NetworkAdapterConfiguration'
    }

    $objWMI = Get-WmiObject @WmiParams | Where-Object { $_.IPAddress.Length -ne 0 } | Select-Object Description, Index, IPAddress, SettingID, MacAddress

    #Test if multiple adapters are returned, if so, break into separate objects
    if ($objWMI -is [array]) {
        foreach ($Object in $objWMI) {
            if (!($null -eq $Object.IPAddress)) {
                [PSCustomObject]@{
                    Desc   = $Object.Description
                    Idx    = $Object.Index
                    Maddr  = $Object.MacAddress
                    SetID  = $Object.SettingID
                    IPAddr = ($Object.IPAddress -split ',' | ForEach-Object {
                            if (!($_ -match "[a-z]")) {
                                $_
                            }
                        }
                    )
                }                            
            }
        }
    }
    # Else create a single object
    else {
        [PSCustomObject]@{
            Desc   = $objWMI.Description
            Idx    = $objWMI.Index
            Maddr  = $objWMI.MacAddress
            SetID  = $objWMI.SettingID
            IPAddr = ($objWMI.IPAddress -split ',' | ForEach-Object {
                    if (!($_ -match "[a-z]")) {
                        $_
                    }
                }
            )
        }
            
    }
}

$ErrorActionPreference = "Stop";

<############
  Variables
############>
$filepath = ".\LLDP_raw.txt"
<############
  Script
############>
$Adapter = Get-ValidNetworkInterface
$tempGUID = $Adapter.SetID

# Check for temp output file
if (Test-Path -Path $filepath -PathType Leaf) {
    $title = "Remove prior log"
    $question = "You have an existing log from this app. Would you like to delete it and overwrite it?"
    $choices = "&Yes", "&No"
    $decision = $Host.UI.PromptForChoice($title, $question, $choices, 0)
    if ($decision -eq 0) {
        Remove-item $filepath -Force
    }
    else {
        exit 1
    }
}

if ($tempGUID -is [array]) {
    $i = 0
    ForEach ($conn in $tempGUID) {
        #Write-host $conn
        $job = Start-Job -inputobject $pwd -Name $conn -ScriptBlock {
            param($conn)
            cmd /c "$input\tcpdump.exe -i \Device\$conn -nn -v -s 1500 -c 1 (ether[12:2]==0x88cc or ether[20:2]==0x2000)" '2> nul'
          } -ArgumentList $conn
        Start-Sleep 30
        While (Get-Job -State "Running") {
            Get-Job
            Start-Sleep 10
            if (Get-Job -State "Running" -ErrorAction:SilentlyContinue) {
                if (test-path -Path $filepath -PathType Leaf) {
                   Add-Content -Path $filepath -value "The network adapter could not be properly enumerated" 
                }
                Break
            }
        }
        $cmdOutput = Receive-Job $job
        Remove-Job $job
          
        $netinfo = [PSCustomObject]@{
            SwitchName     = ($cmdOutput -match "System Name TLV" -split ": ")[1]
            Interface      = ($cmdOutput -match "Subtype Interface Name" -split ": ")[1]
            SwitchMac      = ($cmdOutput -match "Subtype MAC address" -split "\): ")[1]
            SwitchPort     = ($cmdOutput -match "Port ID TLV" -split ": ")[1]
            SwitchPort2    = ($cmdOutput -match "Port Description TLV" -split ": ")[1]
            VLAN           = ($cmdOutput -match "port vlan id" -split ": ")[1]
            SwitchIP       = ($cmdOutput -match "Management Address len" -split ": ")[1]
            SwitchModel    = (($cmdOutput[(($cmdOutput | Out-String).Split("`n") | Select-String "System Description TLV").linenumber])).Trim()
            LocalIPaddress = $Adapter[$i].IPAddr
            LocalMAC       = $Adapter[$i].Maddr
            LocalNic       = $Adapter[$i].Desc
        }
        $netinfo | Out-File $filepath -Append
        $i++
    }
}
else {
    $cmdOutput = cmd /c ".\tcpdump.exe -i \Device\$tempGuid -nn -v -s 1500 -c 1 (ether[12:2]==0x88cc or ether[20:2]==0x2000)" '2> nul'
    # LLDP
    $netinfo = [PSCustomObject]@{
        SwitchName     = ($cmdOutput -match "System Name TLV" -split ": ")[1]
        Interface      = ($cmdOutput -match "Subtype Interface Name" -split ": ")[1]
        SwitchMac      = ($cmdOutput -match "Subtype MAC address" -split "\): ")[1]
        SwitchPort     = ($cmdOutput -match "Port ID TLV" -split ": ")[1]
        SwitchPort2    = ($cmdOutput -match "Port Description TLV" -split ": ")[1]
        VLAN           = ($cmdOutput -match "port vlan id" -split ": ")[1]
        SwitchIP       = ($cmdOutput -match "Management Address len" -split ": ")[1]
        SwitchModel    = (($cmdOutput[(($cmdOutput | Out-String).Split("`n") | Select-String "System Description TLV").linenumber])).Trim()
        LocalIPaddress = $Adapter.IPAddr
        LocalMAC       = $Adapter.Maddr
        LocalNic       = $Adapter.Desc
    }
    $netinfo | Out-File $filepath
}