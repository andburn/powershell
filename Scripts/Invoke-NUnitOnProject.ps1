#Requires -Version 3.0

Param(
	[string]$Platform="AnyCPU",
	[string]$Config="Release"
)

. "$PSScriptRoot\Utils-File.ps1"

$tests = Get-Location | GetChildItemsRegex -Recurse -Regex ".*bin\\($Platform\\)?$Config\\.*Tests?\.dll"

ForEach ($t in $tests) { 
	nunit3-console.exe --noheader --noresult /domain:single $t
}

if (($tests -is [system.array]) -and ($tests.Length -ge 2)) {
	Write-Host -ForegroundColor Yellow "Found $($tests.Length) test assemblies"
}
