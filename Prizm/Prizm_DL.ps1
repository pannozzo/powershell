function Get-ScriptDirectory
{
    Split-Path $script:MyInvocation.MyCommand.Path
}

#If user doesn't supply a version, default to 13.4
$version = If (!$args[0]) {"13.4"} Else {$args[0]};
$current_directory = Get-ScriptDirectory

$server_source = "http://products.accusoft.com/PrizmDoc/" + $version + "/PrizmDocServer-" + $version + ".exe"
$client_source = "http://products.accusoft.com/PrizmDoc/" + $version + "/PrizmDocClient-" + $version + ".exe"

$destination = $current_directory + "\PrizmDoc"
$server = $destination + "\server.exe" 
$client = $destination + "\client.exe"

#Creates path if doesn't exist 
if (!(Test-Path -Path $destination)){
    New-Item -ItemType directory -Path $destination
}

Start-BitsTransfer -Source $server_source -Destination $server
Start-BitsTransfer -Source $client_source -Destination $client
