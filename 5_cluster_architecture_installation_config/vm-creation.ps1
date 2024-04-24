[CmdletBinding()]
Param (
    [Parameter()]
    [string]$Network = "Default Switch",

    [Parameter(Mandatory=$true)]
    [string]$Path,

    [Parameter(Mandatory=$true)]
    [string]$Name,

    [Parameter(Mandatory=$true)]
    [string]$IsoName,

    [Parameter(Mandatory=$true)]
    [ValidateSet("XS","S")]
    [string]$Size,

    [Parameter()]
    [ValidateSet("BIOS", "UEFI")]
    [string]$Firmware = "BIOS",

    [Parameter()]
    [ValidateSet("True", "False")]
    [string]$SecureBoot = $false,

    [Parameter()]
    [ValidateSet("True", "False")]
    [bool]$TPM = $false,

    [Parameter()]
    [ValidateSet("start", "create")]
    [string]$State = "create"
)

$IsoPath = $Path + "\" + $IsoName

if (!(Test-Path $IsoPath)) {
    Write-Error "The specified ISO file '$IsoPath' does not exist."
    return
}

$VMPath = (Get-VMHost).VirtualMachinePath

if ((Test-Path "$Path\$Name")) {
    Write-Error "The specified virtual machine '$Name' does already exist."
    return
}

$vmSettings = @{
    "XS" = @(1, 1GB, 10GB)
    "S"  = @(2, 2GB, 20GB)
}

$vCpu, $vMem, $vHdd = $vmSettings[$Size]

if ($Firmware -eq "BIOS") {
    New-VM -Name $Name `
           -Generation 1 `
           -MemoryStartupBytes $vMem `
           -NewVHDPath "$Path\$Name.vhdx" `
           -NewVHDSizeBytes $vHdd `
           -Switch $Network `
           -Path "$Path\" | `
           Out-Null
    
    Set-VMDvdDrive -VMName $Name -ControllerNumber 1 -ControllerLocation 0 -Path $isoPath

} elseif ($Firmware -eq "UEFI") {
    New-VM -Name $Name `
           -Generation 2 `
           -MemoryStartupBytes $vMem `
           -NewVHDPath "$Path\$Name.vhdx" `
           -NewVHDSizeBytes $vHdd `
           -Switch $Network `
           -Path "$Path\" | `
           Out-Null
    
    if ($SecureBoot -eq $true ) {  
        Set-VMFirmware -VMName $Name -EnableSecureBoot On
        Set-VMFirmware -VMName $Name -SecureBootTemplate MicrosoftUEFICertificateAuthority
    } else {
        Set-VMFirmware -VMName $Name -EnableSecureBoot Off
    }
    Add-VMScsiController -VMName $Name
    Add-VMDvdDrive -VMName $Name -ControllerNumber 1 -ControllerLocation 0 -Path $isoPath

    $DVDDrive = Get-VMDvdDrive -VMName $Name

    Set-VMFirmware -VMName $Name -FirstBootDevice $DVDDrive
    
    if ($TPM -eq $true ) {    
        Set-VMFirmware -VMName $Name -SecureBootTemplate MicrosoftWindows
        Set-VMKeyProtector -VMName $Name -NewLocalKeyProtector
        Enable-VMTPM -VMName $Name
    }
}

Set-VMMemory -VMName $Name -DynamicMemoryEnabled $false

Set-VMProcessor -VMName $Name -Count $vCpu

Set-VMProcessor -VMName $Name -ExposeVirtualizationExtensions $true

Enable-VMIntegrationService -VMName $Name -Name "Guest Service Interface"

Set-VM -Name $Name -AutomaticCheckpointsEnabled $false

if ($State -eq "create") {
    $vmInfo = Get-WmiObject -ComputerName localhost `
                            -Namespace root\virtualization\v2 `
                            -Class Msvm_VirtualSystemSettingData | `
                            Where-Object { $_.ElementName -eq $Name -and $_.BIOSSerialNumber } | `
                            Select-Object ElementName, BIOSSerialNumber | `
                            ConvertTo-Json
    Write-Output $vmInfo
}
if ($State -eq "start") {
    vmconnect.exe localhost $Name
    Start-VM -Name $Name
}
