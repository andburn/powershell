#Requires -Version 3.0

. "$PSScriptRoot\Utils-File.ps1"

Function BuildArtifacts {
Param (
	[switch]$AppendTag,
	[string]$project_name,
	[string]$artifact_prefix,
	[string]$build_dir,
	[string]$release_path
)
	if (-not $env:APPVEYOR_REPO_TAG_NAME) {
		Write-Host -Foreground Yellow "Skipping artifact creation, tag not found."
		Return
	}

	$artifact_postfix = ".zip"
	If ($AppendTag) {
		$artifact_postfix = "_$env:APPVEYOR_REPO_TAG_NAME$artifact_postfix"
	}

    $artifact_filename = "$artifact_prefix$artifact_postfix"
    $artifact = Join-Path -Path $build_dir -ChildPath $artifact_filename
    $bin_path = Join-Path -Path $env:APPVEYOR_BUILD_FOLDER -ChildPath $project_name | Join-Path -ChildPath $release_path

    If (test-path $build_dir) {
        Remove-Item -Recurse -Force $build_dir | out-null
    }
    mkdir $build_dir | out-null
    Copy-Item -Path "$bin_path\*dll" -Destination $build_dir
    & 7z a $artifact "$build_dir\*.dll"
    Push-AppveyorArtifact $artifact -FileName $artifact_filename -DeploymentName release
}

Function GetPackagePath {
Param ([string]$name)

    GetChildItemsRegex -Path "$env:APPVEYOR_BUILD_FOLDER\packages" -Regex ".*$name.*"
}

Function RunCodeCoverage {
Param (
	[string]$Project,
	[string]$Platform="x86",
	[string]$Config="Release"
)

    $OpenCoverPath = GetPackagePath('OpenCover')
    $NunitPath = GetPackagePath('NUnit.ConsoleRunner')
    $CoveragePath = GetPackagePath('Codecov')
    $TestAssembly = "$Project.Tests\bin\$Platform\$Config\$Project.Tests.dll"

    & "$OpenCoverPath\tools\OpenCover.Console.exe" `
        -register:user `
        -target:"$NunitPath\tools\nunit3-console.exe" `
        -targetargs:"--noheader /domain:single $TestAssembly" `
        -filter:"+[$Project]*" -mergebyhash -skipautoprops `
        -output:"coverage.xml"

    & "$CoveragePath\tools\codecov.exe" -f coverage.xml
}
