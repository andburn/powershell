#Requires -Version 3.0

Param(
	[string]$Platform,
	[string]$Config
)

. "$PSScriptRoot\Utils-File.ps1"

Function WriteLineCoverage {
Param([string]$File)

    $color = 'Red'
    $summary = (Get-Content $File | Where { $_ -like '*Line coverage*' }).Trim()
    $match = [regex]::Match($summary, '(\d+\.\d*)\%')
    if ($match.Success) {
        $percentage = [double]$match.Captures.Groups[1].Value
        if ($percentage -ge 50) { $color = 'Yellow' }
        if ($percentage -ge 85) { $color = 'Green' }
    }    
    Write-Host -ForegroundColor $color $summary
}

Function WriteTestCount {
Param([string]$Summary)

    $color = 'Green'
    $line = 'Test Count: Error'
    $match = [regex]::Match($Summary, 'Test Count: (\d+), Passed: (\d+), Failed: (\d+), Inconclusive: (\d+), Skipped: (\d+)')
    if ($match.Success) {
        $line = $match.Captures.Groups[0].Value
        $failed = [int]$match.Captures.Groups[3].Value
        if ($failed -ge 1) { $color = 'Red' }
    }    
    Write-Host -ForegroundColor $color $line 
}

$coverage_dir = "coverage"
$project_path = (Get-Location).Path
$project_name = (GetChildItemsRegex -Path $project_path -Regex ".*\.sln").Replace("$project_path\", '').Replace('.sln','')
$test_dll = GetChildItemsRegex -Path $project_path -Recurse -Regex ".*bin\\($Platform\\)?$Config\\.*Tests?\.dll"

if (($test_dll -is [system.array]) -and ($test_dll.Length -ge 2)) {
    Write-Host -ForegroundColor Red "Found more than one test assembly"
    Return
}

Remove-Item "$project_path\$coverage_dir\*" -Recurse

$cover_output = & OpenCover.Console.exe `
    -register:user `
    -target:'nunit3-console.exe' `
    -targetargs:"--noheader --noresult /domain:single $test_dll" `
    -filter:"+[$project_name]*" -mergebyhash -skipautoprops `
    -output:"$project_path\$coverage_dir\opencover.results.xml" `
    2>&1

WriteTestCount $cover_output

& ReportGenerator.exe `
    -verbosity:Error `
    -reports:"$project_path\$coverage_dir\opencover.results.xml" `
    -targetdir:"$project_path\$coverage_dir" `
    -reporttypes:"TextSummary;Html"

WriteLineCoverage "$project_path\$coverage_dir\Summary.txt"