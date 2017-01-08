#Requires -Version 3.0

Param(
	[string]$File,
	[string]$Date
)

$f = Get-Item $File
$d = Get-Date $Date
$f.creationtime = $d
$f.lastaccesstime = $d
$f.lastwritetime = $d