Param(	
	[string]$Platform,
	[string]$Config
)

$regex = ".*bin\\($Platform\\)?$Config\\.*Test.*\.dll"
$tests = (Get-Location | Get-ChildItem -Recurse | Where { $_.FullName -match $regex }).FullName

ForEach ($t in $tests)
{ 
	nunit3-console.exe --noheader --noresult /domain:single $t
}

if (($tests -is [system.array]) -and ($tests.Length -ge 2))
{
	Write-Host -ForegroundColor Yellow "Found $($tests.Length) test assemblies"
}
