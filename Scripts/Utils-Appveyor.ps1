#Requires -Version 3.0

. "$PSScriptRoot\Utils-File.ps1"

Function BuildArtifacts {
Param (
	[string]$project_name,
	[string]$artifact_prefix,
	[string]$build_dir,
	[string]$release_path
)
	if (-not $env:APPVEYOR_REPO_TAG_NAME) {
		Write-Host -Foreground Yellow "Skipping artifact creation, tag not found."
		Return
	}

    $artifact_filename = "$($artifact_prefix)_$env:APPVEYOR_REPO_TAG_NAME.zip"
    $artifact = Join-Path -Path $build_dir -ChildPath $artifact_filename
    $bin_path = Join-Path -Path $env:APPVEYOR_BUILD_FOLDER -ChildPath $project_name | Join-Path -ChildPath $release_path

    If (test-path $build_dir) {
        Remove-Item -Recurse -Force $build_dir | out-null
    }
    mkdir $build_dir | out-null
    Copy-Item -Path "$bin_path\*dll" -Destination $build_dir
    & 7z a $artifact $build_dir
    Push-AppveyorArtifact $artifact -FileName $artifact_filename -DeploymentName release
}

Function GetPackagePath {
Param ([string]$name)

    GetChildItemsRegex -Path "$env:APPVEYOR_BUILD_FOLDER\packages" -Regex ".*$name.*"
}

Function RunCodeCoverage {
Param ([string]$project)

    $OpenCoverPath = GetPackagePath('OpenCover')
    $NunitPath = GetPackagePath('NUnit.ConsoleRunner')
    $CoverallsPath = GetPackagePath('coveralls')
    $test_dll = GetChildItemsRegex -Path $env:APPVEYOR_BUILD_FOLDER -Recurse -Regex ".*bin\\x86\\Release\\.*Test.*\.dll"

    & "$OpenCoverPath\tools\OpenCover.Console.exe" `
        -register:user `
        -target:"$NunitPath\tools\nunit3-console.exe" `
        -targetargs:"--noheader /domain:single $test_dll" `
        -filter:"+[$project]*" -mergebyhash -skipautoprops `
        -output:"coverage.xml"

    & "$CoverallsPath\tools\coveralls.net.exe" --opencover coverage.xml
}
