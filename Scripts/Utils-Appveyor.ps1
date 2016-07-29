#Requires -Version 3.0

. "$PSScriptRoot\Utils-File.ps1"

Function BuildArtifacts {
Param (
	[string]$project_name,
	[string]$artifact_prefix,
	[string]$build_dir,
	[string]$release_path
)

    $artifact_filename = "$($artifact_prefix)_$env:APPVEYOR_REPO_TAG_NAME.zip"
    $artifact = Join-Path -Path $build_dir -ChildPath $artifact_filename

    mkdir $build_dir
    Copy-Item -Path "$env:APPVEYOR_BUILD_FOLDER\$release_path\*dll*" -Destination $build_dir
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
