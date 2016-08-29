#Requires -Version 3.0

Param(
	[string]$Path,
	[string]$Config="Debug",
	[string]$Platform="AnyCPU",
	[switch]$Quiet,
	[switch]$NoBuildEvents
)

. "$PSScriptRoot\Utils-File.ps1"

$nl = [Environment]::NewLine

$BuildEvents = ""
if ($NoBuildEvents) {
	$BuildEvents = "PreBuildEvent=;PostBuildEvent=;"
}

$Verbosity = "normal"
if ($Quiet) {
	$Verbosity = "minimal"
}

if (-not $Path) {
	$Path = Get-Location | GetChildItemsRegex -Regex ".*\.sln$"
}

if (($Path -is [system.array]) -and ($Path.Length -ge 2)) {
	Write-Host -ForegroundColor Red "Found more than one project solution"
    Return
}

Write-Host "Using MsBuild: " (Get-Command msbuild).Source
Write-Host "Building: " $Path $nl
& msbuild $Path "/property:$($BuildEvents)SolutionDir=.\;Configuration=$Config;Platform=$Platform" /verbosity:$Verbosity /nologo