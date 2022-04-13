echo " Given below is the Hardware Description"
function HardwareDescription {
get-wmiobject -class win32_computersystem |
 foreach{
            new-object -TypeName psobject -Property @{
                      Domain = $_.Domain
                       Manufacturer = $_.Manufacturer
                       Model = $_.Model
                       Name = $_.Name
                       PrimaryOwnerName = $_.PrimaryOwnerName
                       "TotalPhysicalMemory(MB)" = $_.TotalPhysicalMemory/1mb
 }| Format-Table Domain, Manufacturer, Model, Name, PrimaryOwnerName,"TotalPhysicalMemory(MB)"
 }
 }
 HardwareDescription


 echo " Given below is the Operating System Description"
 function OperatingSystem {
 get-wmiobject -class win32_operatingsystem |
  foreach{
             new-object -TypeName psobject -Property @{
                       PSComputerName = $_.PSComputerName
                       Version = $_.Version
}| Format-Table PSComputerName, Version
}
}
OperatingSystem


echo " Given below is the Processor Description"
function ProcessorDescription {
get-wmiobject -class win32_processor |
 foreach {
            new-object -TypeName psobject -Property @{
                       Description = $_.Description
                       L3CacheSize = $_.L3CacheSize
                       MaxClockSpeed = $_.MaxClockSpeed
                       NumberOfCores = $_.NumberOfCores

}| Format-list Description, L3CacheSize, L3CacheSpeed, MaxClockSpeed, NumberOfCores
}
}
ProcessorDescription


echo " Given below is Summary of RAM"
function RAMSummary {
get-wmiobject -class win32_physicalmemory |
 foreach {
  new-object -TypeName psobject -Property @{
  Manufacturer = $_.manufacturer
  "Size(MB)" = $_.capacity/1mb
  Description = $_.Description
  Bank = $_.banklabel
  Slot = $_.devicelocator
  }
  $totalcapacity += $_.capacity/1mb
 }| Format-Table Manufacturer, "Size(MB)", Bank, Slot, Description
 "Total RAM: ${totalcapacity}MB "
}
RAMSummary 


echo " Given below is Summary of the Physical Drives"
function SUmmaryPhysicalDrives {
$diskdrives = Get-CIMInstance CIM_diskdrive

   foreach ($disk in $diskdrives) {
       $partitions = $disk|get-cimassociatedinstance -resultclassname CIM_diskpartition
       foreach ($partition in $partitions) {
             $logicaldisks = $partition | get-cimassociatedinstance -resultclassname CIM_logicaldisk
             foreach ($logicaldisk in $logicaldisks) {
                      new-object -typename psobject -property @{ManufacturerOfDisk=$disk.Manufacturer
                                                                SpaceOccupied=($disk.size - $logicaldisk.FreeSpace) /1gb -as [int]
                                                                ModelOfDiskDrive=$disk.model
                                                                FreeSpaceOfLogicalDisk=$logicaldisk.FreeSpace
                                                               "SizeOfDiskDrive(GB)"=$disk.size / 1gb -as [int]
                                                                 }|Format-table ManufacturerOfDisk, SpaceOccupied, ModelOfDiskDrive, FreeSpaceOfLogicalDisk, "SizeOfDiskDrive(GB)"
 }
   }
   }
 }
   SummaryPhysicalDrives


 echo " Network Adapter Configuration Report"
 function NetworkAdapter {
 Get-CimInstance -className Win32_NetworkAdapterConfiguration | Where-Object IPEnabled -EQ "True" |
    
    foreach{
                New-Object -TypeName psobject -Property @{Description =$_.Description
                                                          Index =$_.Index
                                                          IPAddress=$_.ipaddress
                                                          SubnetMask = $_.Ipsubnet
                                                          DNSName=$_.DNSDomain
                                                          DNSServer=$_.DNSServerSearchOrder
}|Format-Table Description,Index,IPAddress, Subnetmask,DNSName,DNSServer
}   
}
NetworkAdapter


echo " Given below is Video COntroller Description"
function VideoController {
get-wmiobject -class win32_videocontroller |
 foreach{
              new-object -TypeName psobject -Property @{
                        Description = $_.Description
                        VideoArchitecture = $_.VideoArchitecture
                        CurrentScreenResolution =[string]$_.CurrentHorizontalResolution + "x" +  $_.CurrentVerticalResolution
 }| Format-Table Description, VideoArchitecture, CurrentScreenResolution
 }
 }
 VideoController