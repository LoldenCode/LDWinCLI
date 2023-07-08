<#
    .SYNOPSIS
        Pull all online computers in domain's LLDP data and convert to rudimentary network diagram
    .DESCRIPTION
        Example document created for better understanding of the use of the Get-SwitchInfo tool. If no list of PCs are passed, the tool will query Active Directory and build list of online PCs, then use those to build out the map.
    .PARAMETER Computers
        An array of all of the FQDN or IP addresses of PCs on the network
        #Repeat for more than 1 parameter
    .NOTES
        Version:  1.1
        Author:  Alden Wilson
        Creation Date:  07-05-2023
        Last Update:  07-06-2023
    .EXAMPLE
        Get-NetworkMap $Computers


#>
param (
    [Parameter(ValuefromPipeline = $True)]
    $Computers
)
<#############
  Functions
############>

function bytesToString {

}

<#

{
  return btoa(bytesToString(pako.deflateRaw(encodeURIComponent(data))));
    //find 'encodeCheckbox'
    //find deflatecheckbox
    //find base64checkbox
    function parseXml(xml)
    {
        if (window.DOMParser)
        {
            var parser = new DOMParser();

            return parser.parseFromString(xml, 'text/xml');
        }
        else
        {
            var result = createXmlDocument();

            result.async = 'false';
            result.loadXML(xml);

            return result;
        }
    };

};
#>
    function encode {
        param(
            [Parameter]$data
        )
        # encodeURIComponent
        
        

        $data | ForEach-Object {
            $compressedBytes = [System.Convert]::FromBase64String($_)
            $ms = New-Object System.IO.MemoryStream
            $ms.write($compressedBytes, 0, $compressedBytes.Length)
            $ms.Seek(0,0) | Out-Null
            $cs = New-Object System.IO.Compression.GZipStream($ms, [System.IO.Compression.CompressionMode]::Decompress)
            $sr = New-Object System.IO.StreamReader($cs)
            $sr.ReadToEnd()
          }

        # deflateRaw
        $base64data = "C8nILFY1MgATiUBcklpcAgA="
        $data = [System.Convert]::FromBase64String($base64data)
        $ms = New-Object System.IO.MemoryStream
        $ms.Write($data, 0, $data.Length)
        $ms.Seek(0,0) | Out-Null
        $sr = New-Object System.IO.StreamReader(New-Object System.IO.Compression.DeflateStream($ms, [System.IO.Compression.CompressionMode]::Decompress))
          while ($line = $sr.ReadLine()) {  
            $line
        }
    
        # btoa
        $btoa = [convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Text))
        return $btoa
    }
    function getDesc {
        param(
        [parameter]$csvString
        )
    
        $result = @()
        for ($i = 0; $i -lt $csvString.length; ++$i) {
            if (!($csvString[$i].startswith("#"))) {
                $result += $csvString[$i].Insert(0,"#")
            } 
        }
        $result = $result -join "`r`n"
    }

    function Get-CompressedByteArray { 
	[CmdletBinding()] 
	Param 
	( 
         [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)][byte[]] $byteArray = $(Throw("-byteArray is required")) 
	) 

	Process 
	{ 
 # Write-Verbose "Get-CompressedByteArray" 
 [System.IO.MemoryStream] $output = New-Object System.IO.MemoryStream 
 $gzipStream = New-Object System.IO.Compression.DeflateStream $output, ([IO.Compression.CompressionMode]::Compress) 
 $gzipStream.Write( $byteArray, 0, $byteArray.Length ) 
 $gzipStream.Close() 
 $output.Close() 
 $tmp = $output.ToArray() 
 # Write-Output $tmp 
	}
}


function create {
    param(
        [parameter(mandatory=$true)]$url,
        [parameter(mandatory=$true)]$csvString
    )
    $result = $csvString -split "`r`n" -join "\n"

    # Desired output, excluding the deflate - {"url":"https://jgraph.github.io/drawio-diagrams/diagrams/orgchart.csv","format":"csv","data":"#label: %name%<br><i style=\"color:gray;\">%position%</i><br><a href=\"mailto:%email%\">Email</a>\n#style: label;image=%image%;whiteSpace=wrap;html=1;rounded=1;fillColor=%fill%;strokeColor=%stroke%;\n#parentstyle: swimlane;whiteSpace=wrap;html=1;childLayout=stackLayout;horizontal=1;horizontalStack=0;resizeParent=1;resizeLast=0;collapsible=1;"}
    $query = '{"url":"' + $url+ '", "format":"csv","data":"' + $result + '"}'
    $sanitizedquery = [uri]::EscapeDataString($query)
    $inlinescript = $sanitizedquery
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($InlineScript) 
    $CompressedBytes = Get-CompressedByteArray $bytes

}


<############
  Script
############>

# Build out some temporary ArrayLists
[System.Collections.ArrayList]$OnlinePCs = @()
[System.Collections.ArrayList]$invalidWorkstations = @()
[System.Collections.ArrayList]$WorkingWorkstations = @()

# if no input is passed, grab all AD computers
if ($null -eq $Computers) {
    try {
        $Workstations = (Get-ADComputer -Filter *).name
    }
    catch [System.Management.Automation.CommandNotFoundException] {
        Write-Error -Message "If not passing a Workstation into this, the tool must be ran on a machine with access to the Get-ADComputer cmdlet."
        Exit 1;
    }
}
elseif ($Computers.count -eq 1) {
    Write-Error -Message "This tool is intended to be ran across multiple devices to map out the network. Please include at least two devices in your query."
}
ForEach ($Computer in $Workstations) {
    if (Test-Connection -ComputerName $Computer -Quiet -Count 1) {
        $OnlinePCs.Add($Computer) | Out-Null
    }
}
ForEach ($OnlinePC in $OnlinePCs) {
    $testSession = New-PSSession -Computer $OnlinePC
    if (-not($testSession)) {
        $invalidWorkstations.Add($OnlinePC) | out-Null
    }
    else {
        $WorkingWorkstations.Add($OnlinePC) | out-null
        Remove-PSSession $OnlinePC
    }
}
$result = (.\Get-SwitchInfo.ps1 -ComputerName $WorkingWorkstations)

<############
  Exports
############>

$parsed = $result | select-object Computer, PortDescription, @{name = "IPAddress"; Expression = { $_.IPAddress } }, ChassisID, Device, SystemDescription, @{name = "shape"; Expression = {'mxgraph.cisco.computers_and_peripherals.pc'}} | ConvertTo-Csv -Delimiter ',' -NoTypeInformation
$routers = $result | Sort-Object Device |select-object Device | Get-Unique -AsString
foreach ($router in $routers.device) {
    $parsed += '"' + $Router +'","","","","","mxgraph.cisco.switches.layer_3_switch"'
}

# $parsed contains the spreadsheet of all devices

$csvString = '##Network Diagram generated by PsDrawIO
# label: %Computer%
## style: shape=%shape%;fillColor=%fill%;strokeColor=%stroke%;verticalLabelPosition=bottom;aspect=fixed;
# style: label;shape=%shape%;whiteSpace=wrap;html=1;rounded=1;fillColor=%fill%;strokeColor=%stroke%;
# namespace: csvimport-
# connect: {"from": "Device", "to": "Computer", "invert": false, "fromlabel": "PortDescription", \
#          "style": "text=%PortDescription%;curved=1;endArrow=blockThin;endFill=1;fontSize=11;"}
# width: 40
# height: 40
# ignore: id,fill,stroke,refs
# nodespacing: 20
# levelspacing: 20
# edgespacing: 20
# layout: horizontalflow
## CSV data starts below this line'