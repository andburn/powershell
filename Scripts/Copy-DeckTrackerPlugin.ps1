#Requires -Version 3.0

Param(	
	[string]$ProjectDir,
	[string]$Config="Release",
	[string]$Platform="x86"
)

$AppDir = "$env:LOCALAPPDATA\HearthstoneDeckTracker"
$DataDir = "$env:APPDATA\HearthstoneDeckTracker"
$ProjectName = (Get-ChildItem -Path $ProjectDir | Where { $_.Name -match ".+?\.sln" }).BaseName

if (-not $ProjectDir) {
	$ProjectDir = $(Get-Location).Path
}

$hdt = Get-Process "HearthstoneDeckTracker" -ErrorAction SilentlyContinue
if ($hdt) {
  Write-Output "Closing HDT"
  $hdt.CloseMainWindow() | out-null
  Sleep 4
  if (!$hdt.HasExited) {
    Write-Output "Forcing shutdown"
    $hdt | Stop-Process -Force
  }    
}
Remove-Variable hdt

if (-not (test-path "$DataDir\Plugins")) {
	mkdir "$DataDir\Plugins" | out-null
}

if (test-path "$DataDir\Plugins\$ProjectName") {
	Remove-Item "$DataDir\Plugins\$ProjectName\*" -Recurse -Force 
} else {
	mkdir "$DataDir\Plugins\$ProjectName" | out-null
}

Copy-Item "$ProjectDir\$($ProjectName)\bin\$Platform\$Config\$ProjectName*.dll" "$DataDir\Plugins\$ProjectName" -Force
Sleep 2
Write-Output "Starting HDT"
Start-Process "$AppDir\Update.exe" -ArgumentList "--processStart","HearthstoneDeckTracker.exe"

