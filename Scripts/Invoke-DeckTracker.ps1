Param(	
	[switch]$Data,
	[switch]$App,
	[switch]$Log,
	[string]$PluginLog
)

$Name = "HearthstoneDeckTracker"
$AppDir = "$env:LOCALAPPDATA\$Name"
$DataDir = "$env:APPDATA\$Name"

if ($App) {
	Write-Host $AppDir
	Invoke-Item $AppDir
} elseif ($Data) {
	Write-Host $DataDir
	Invoke-Item $DataDir
} elseif ($Log) {
	Get-Content -Wait "$DataDir\Logs\hdt_log.txt"
} elseif ($PluginLog) {
	Get-Content -Wait "$DataDir\$($PluginLog).log"
} else {
	Start-Process "$AppDir\Update.exe" -ArgumentList "--processStart","HearthstoneDeckTracker.exe"
}