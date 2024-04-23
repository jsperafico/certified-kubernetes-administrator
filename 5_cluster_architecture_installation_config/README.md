# Cluster Architecture, Installation and Configuration

Kubeadm allows to quickly provision a secure Kubernetes cluster.

You will require 2 Linux-based Virtual machines.

```powershell
$DefaultVmPath = "C:\vms"
$DebianISOUrl = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.5.0-amd64-netinst.iso"
$DebianISOPath = "$DefaultVmPath\debian.iso"

Invoke-WebRequest -Uri $DebianISOUrl -OutFile $DebianISOPath

$SwitchName = "K8s-Switch"
$NetworkAdapterName = "Ethernet"

New-VMSwitch -Name $SwitchName -SwitchType Internal

$MainName = "k8s-main"
$MainCpu = 2

New-VM -Name $MainName -Generation 2 -MemoryStartupBytes 2GB -SwitchName $SwitchName

New-VHD -Path "$DefaultVmPath\$MainName.vhdx" -SizeBytes 20GB
Add-VMHardDiskDrive -VMName $MainName -Path "$DefaultVmPath\$MainName.vhdx"
Add-VMDvdDrive -VMName $MainName -Path $DebianISOPath

Set-VMFirmware -VMName $MainName -FirstBootDevice (Get-VMDvdDrive -VMName $MainName)
Set-VMFirmware -VMName $MainName -EnableSecureBoot Off

Set-VMMemory -VMName $MainName -DynamicMemoryEnabled $false
Set-VMProcessor -VMName $MainName -ExposeVirtualizationExtensions $true
Enable-VMIntegrationService -VMName $MainName -Name "Guest Service Interface"
Set-VMProcessor $MainName -Count $MainCpu
Set-VM -Name $MainName -AutomaticCheckpointsEnabled $false

vmconnect.exe localhost $Name
Start-VM -Name $MainName
```

Serve your `preseed.cfg` in any webserver, like:

```powershell
python -m http.server --directory .\
```

# And now?

|[Previous](../4_storage/README.md)|[Next](../6_troubleshooting/README.md)|