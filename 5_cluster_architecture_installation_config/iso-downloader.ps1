[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)]
    [string]$Path,

    [Parameter(Mandatory=$true)]
    [string]$FileName,
    
    [Parameter()]
    [string]$Url = "https://releases.ubuntu.com/22.04/ubuntu-22.04.4-live-server-amd64.iso"
)

$IsoPath = "$Path\$FileName.iso"

Invoke-WebRequest -Uri $Url -OutFile $IsoPath  -TimeoutSec 600