#Requires -Version 3.0

Param(
	[Parameter(Mandatory=$true)][string]$RootDir
)

. "$PSScriptRoot\Utils-GitHub.ps1"

$ExtractPath = Join-Path -Path $RootDir -ChildPath "Hearthstone Deck Tracker"
If (test-path $ExtractPath)
{
	Remove-Item -Recurse -Force $ExtractPath
}
GetLatestRelease $RootDir "HearthSim" "Hearthstone-Deck-Tracker"
Rename-Item -NewName "$ExtractPath\HearthstoneDeckTracker.exe" "$ExtractPath\Hearthstone Deck Tracker.exe"
