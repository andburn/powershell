#Requires -Version 3.0

Param(
	[Parameter(Mandatory=$true)][string]$RootDir
)

. "$PSScriptRoot\Utils-GitHub.ps1"

GetLatestRelease $RootDir "HearthSim" "Hearthstone-Deck-Tracker"
$ExtractPath = Join-Path -Path $RootDir -ChildPath "Hearthstone Deck Tracker"
Rename-Item -NewName "$ExtractPath\HearthstoneDeckTracker.exe" "$ExtractPath\Hearthstone Deck Tracker.exe"
