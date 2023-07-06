<#
    .SYNOPSIS
        Pull all online computers in domain's LLDP data and convert to rudimentary network diagram
    .DESCRIPTION
        Example document created for better understanding of the use of the Get-SwitchInfo tool
    .PARAMETER Computers
        An array of all of the FQDN or IP addresses of PCs on the network
        #Repeat for more than 1 parameter
    .NOTES
        Version:  1.0
        Author:  Alden Wilson
        Creation Date:  07-05-2023
        Last Update:  07-05-2023
    .EXAMPLE
        #Repeat for more than 1 example
#>
param (
    $Computers
)
<############
  Functions
############>

function VerifyAccessible {
    #[CmdletBinding(DefaultParametersetName = 'Capture')]
    # param(
    #     [Parameter(ParameterSetName = 'Capture')]
    #     [ValidateNotNull()]
    #     [System.Management.Automation.Credential()]
    #     [PSCredential]$Credential = [System.Management.Automation.PSCredential]::Empty
    # )
    
    #process 
    {
        $PSCredential = @{}
        if ($PSBoundParameters.ContainsKey('Credential')) {
            $PSCredential.Add('Credential',$Credential)
        }
        # [System.Collections.ArrayList]$invalidWorkstations =@()
        # [System.Collections.ArrayList]$WorkingComputers =@()
        # foreach ($Computer in $Computers) {

        #     Try {
        #         New-CimSession ComputerName $Computer -ErrorAction Stop
        #         $WorkingComputers.Add($Computer)
        #     }
        #     Catch [Microsoft.Management.Infrastructure.CimException] {
        #         $invalidWorkstations.Add($Computer)
        #         continue
        #     }
        # }
    }
}

<############
  Variables
############>

<############
  Testing grounds
############>
<#
# Verify input
if ($Computers.count -gt 1) {
Write-Host "There are $($Computers.count) items input!"
}
elseif ($Computers.count -eq 1) {
    Write-Host "one value"
}
else {
    Write-Host $Computers.count
}
#>
<############
  Script
############>

#VerifyAccessible

[System.Collections.ArrayList]$invalidWorkstations =@()
[System.Collections.ArrayList]$WorkingComputers =@()
foreach ($Computer in $Computers) {
    Try {
        #New-CimSession ComputerName $Computer -ErrorAction Stop
        $WorkingComputers.Add($Computer) | out-null
    }
    Catch [Microsoft.Management.Infrastructure.CimException] {
        $invalidWorkstations.Add($Computer) | out-Null
        continue
    }
}

### Test case

[System.Collections.ArrayList]$WorkingComputers1 = @()
$WorkingComputers1.Add("192.168.1.2") |out-null
$WorkingComputers1.Add("192.168.1.2") |out-null
$WorkingComputers1.Add("192.168.1.2") |out-null
$WorkingComputers1.Add("192.168.1.2") |out-null
#Write-host $WorkingComputers1

.\Get-SwitchInfo_test.ps1 -ComputerName $WorkingComputers1
<############
  Exports
############>

#Export-ModuleMember -Function FunctionName
#Export-ModuleMember -Variable VariableName