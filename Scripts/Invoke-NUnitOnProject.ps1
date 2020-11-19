#Requires -Version 3.0

Param(
	[string]$Platform="x86",
	[string]$Config="Release"
)

. "$PSScriptRoot\Utils-File.ps1"

If ($Platform -eq "AnyCPU") {
	$TestRegEx = ".*bin\\$Config\\.*Tests?\.dll$"
} Else {
	$TestRegEx = ".*bin\\$Platform\\$Config\\.*Tests?\.dll$"
}
$NUnit = Get-Location | GetChildItemsRegex -Recurse -Regex ".*NUnit.ConsoleRunner.*nunit3-console.exe$"
$Tests = Get-Location | GetChildItemsRegex -Recurse -Regex $TestRegEx

ForEach ($t in $Tests) {
	& $NUnit --noheader --noresult /domain:single $t
}

If (($tests -is [system.array]) -and ($Tests.Length -ge 2)) {
	Write-Host -ForegroundColor Yellow "Found $($tests.Length) test assemblies"
	ForEach ($t in $Tests) {
		Write-Host $t
	}
}
