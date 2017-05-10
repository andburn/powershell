#Requires -Version 3.0

Param(
	[string]$Platform="AnyCPU",
	[string]$Config="Release"
)

. "$PSScriptRoot\Utils-File.ps1"

Function WriteLineCoverage {
Param([string]$File)

    $color = 'Red'
    $summary = (Get-Content $File | Where { $_ -like '*Line coverage*' }).Trim()
    $match = [regex]::Match($summary, '(\d+\.\d*)\%')
    if ($match.Success) {
        $percentage = [double]$match.Captures.Groups[1].Value
        if ($percentage -ge 85) { $color = 'Green' }
        elseif ($percentage -ge 50) { $color = 'Yellow' }
    }    
    Write-Host -ForegroundColor $color $summary
}

Function WriteTestCount {
Param([string]$Summary)

	$regex = -join 'Test Count:\s*(?<count>\d+),\s*',
		'Passed:\s*(?<pass>(\d+)),\s*',
		'Failed:\s*(?<fail>\d+),\s*',
		'Warnings:\s*(?<warn>\d+),\s*',
		'Inconclusive:\s*(?<unknown>\d+),\s*',
		'Skipped:\s*(?<skip>\d+)'
    $color = 'Green'
    $line = 'Test Count: Error'
    $match = [regex]::Match($Summary, $regex)
    if ($match.Success) {
		$total = [int]$match.Groups["count"].Value
        $failed = [int]$match.Groups["fail"].Value
		$passed = [int]$match.Groups["pass"].Value
		$warning = [int]$match.Groups["warn"].Value
		$line = "Tests: $passed of $total passed"
        if ($failed -ge 1) {  $color = 'Red' }
		elseif ($warning -ge 1) { $color = 'Yellow' }
    }    
    Write-Host -ForegroundColor $color $line 
}

If ($Platform -eq "AnyCPU") {
	$TestRegEx = ".*bin\\$Config\\.*Tests?\.dll$"
} Else {
	$TestRegEx = ".*bin\\$Platform\\$Config\\.*Tests?\.dll$"
}

$coverageDir = "coverage"
$projectPath = (Get-Location).Path
$projectName = (GetChildItemsRegex -Path $projectPath -Regex ".*\.sln").Replace("$projectPath\", '').Replace('.sln','')
$tests = GetChildItemsRegex -Path $projectPath -Recurse -Regex $TestRegEx
# get the exe paths from the nuget packages, not local
$exeNUnit = Get-Location | GetChildItemsRegex -Recurse -Regex ".*NUnit.ConsoleRunner.*nunit3-console.exe$"
$exeOpenCover = Get-Location | GetChildItemsRegex -Recurse -Regex ".*OpenCover.Console.exe$"
$exeReportGen = Get-Location | GetChildItemsRegex -Recurse -Regex ".*ReportGenerator.exe$"

# want only one test assembly
if (-not $tests) {
	Write-Host -ForegroundColor Red "No test assembly found ($Platform/$Config)"
    Return
} elseif (($tests -is [system.array]) -and ($tests.Length -ge 2)) {
    Write-Host -ForegroundColor Red "Found more than one test assembly ($Platform/$Config)"
	ForEach ($t in $tests) {
		Write-Host $t
	}
    Return
}

# clean the coverage directory
if (Test-Path -Path "$projectPath\$coverageDir") {
	Remove-Item -ErrorAction SilentlyContinue "$projectPath\$coverageDir\*" -Recurse
} else {
	New-Item -ErrorAction SilentlyContinue -ItemType directory -Path "$projectPath\$coverageDir" | Out-Null
}

$cover_output = & $exeOpenCover `
    -register:user `
    -target:$exeNUnit `
    -targetargs:"--noheader --noresult /domain:single $tests" `
    -filter:"+[$projectName]*" -mergebyhash -skipautoprops `
    -output:"$projectPath\$coverageDir\opencover.results.xml"
    
WriteTestCount $cover_output

& $exeReportGen `
    -verbosity:Error `
    -reports:"$projectPath\$coverageDir\opencover.results.xml" `
    -targetdir:"$projectPath\$coverageDir" `
    -reporttypes:"TextSummary;Html"

WriteLineCoverage "$projectPath\$coverageDir\Summary.txt"