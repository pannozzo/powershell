#USAGE: .\Make-VM.ps1 VALID_ISO_NAME DRIVE_SIZE
#https://mcpmag.com/articles/2017/03/09/creating-a-vm-in-hyperv-using-ps.aspx

#TODO: Configure so ISO's are not a user specific path 
#TODO: Clean up splitter

#Get ISO name from first argument
$input_iso = $args[0]
$drive_size = $args[1]
$iso_directory = "C:\Users\tpannozzo\Documents\Thom_Stuff\VM\"
$input_iso_path =  $iso_directory + $input_iso + ".iso"
$new_vhd_path = "C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks\" + $input_iso + ".vhdx"

if (!$drive_size){
    $drive_size = 60GB
    "No drive sized specified, defaulted to 60GB"
}

#Fail if ISO not given
if(!$input_iso)
{
    "ERROR: use format '.\Make-VM.ps1 VALID_ISO_NAME DRIVE_SIZE' "
    exit
}

#Fail if ISO doesn't actually exist 
if (!(Test-Path -Path $input_iso_path)){
    "ERROR: ISO does not exist at " + $input_iso_path
    "Try one of these filenames: "
    ls $iso_directory
    exit
}

#If similarly named VM already exists, change path name
if (Test-Path -Path $new_vhd_path){
    while ($i++ -ne 10){
        $new_vhd_path = "C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks\" + $input_iso + "_" + $i + ".vhdx"
        if (Test-Path -Path $new_vhd_path) {Continue}
        else {Break}
    }
}

#If existing external switch does not exist, create it
if(!($switch = Get-NetAdapter -Name "*External*")) 
{
    $switch = New-VMSwitch -name ExternalSwitch -NetAdapterName Ethernet -AllowManagementOS $true 
} 

#Extract actual switch name from Get-NetAdapter's data 
$switch = (($switch.Name).split("("")"))[1]


$new_VM_parameters = @{

  Name = $input_iso
  MemoryStartUpBytes = 4GB
  Path = "C:\ProgramData\Microsoft\Windows\Hyper-V"
  SwitchName =  $switch
  NewVHDPath =  $new_vhd_path
  NewVHDSizeBytes = $drive_size
  ErrorAction =  'Stop'
  Verbose =  $True

  }

$setup_VM_parameters = @{

  ProcessorCount =  3
  DynamicMemory =  $True
  MemoryMinimumBytes =  4GB
  MemoryMaximumBytes =  8Gb
  ErrorAction =  'Stop'
  PassThru =  $True
  Verbose =  $True

  }

$setup_VMDvd_parameters = @{

  VMName =  $input_iso
  Path = $input_iso_path
  ErrorAction =  'Stop'
  Verbose =  $True

  }

$VM = New-VM @new_VM_parameters 
$VM = $VM | Set-VM @setup_VM_parameters 
Set-VMDvdDrive @setup_VMDvd_parameters

$VM | Start-VM -Verbose
