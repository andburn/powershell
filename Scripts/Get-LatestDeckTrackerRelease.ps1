#Requires -Version 3.0

Param(
	[Parameter(Mandatory=$true)][string]$RootDir
)

. "$PSScriptRoot\Utils-GitHub.ps1"

$Dir = Resolve-Path $RootDir
$ExtractPath = Join-Path -Path $Dir -ChildPath "Hearthstone Deck Tracker"
If (test-path $ExtractPath)
{
	Remove-Item -Recurse -Force $ExtractPath
}
GetLatestRelease $Dir "HearthSim" "Hearthstone-Deck-Tracker" -Scrape
Rename-Item -NewName "$ExtractPath\HearthstoneDeckTracker.exe" "$ExtractPath\Hearthstone Deck Tracker.exe"
