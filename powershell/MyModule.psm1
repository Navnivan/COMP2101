function welcome {
write-output "Welcome to powershell $env:computername Overlord $env:username"
$now = get-date -format 'HH:MM tt on dddd'
write-output "It is $now."
}

function get-cpuinfo {
get-CimInstance CIM_processor | format-list NumberOfCores, Manufacturer, CurrentClockSpeed, MaxClockSpeed, Name, Caption
}

function get-mydisks {
get-disk | format-table  Manufacturer, Model, SerialNumber, FirmwareRevision, Size
}

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

 function OperatingSystem {
 get-wmiobject -class win32_operatingsystem |
  foreach{
             new-object -TypeName psobject -Property @{
                       PSComputerName = $_.PSComputerName
                       Version = $_.Version
}| Format-Table PSComputerName, Version
}
}


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