#Requires -Version 3.0

Function GetLatestRelease {
Param(
	[string]$RootDir,
	[string]$Owner,
	[string]$Repo
)

	Add-Type -AssemblyName System.IO.Compression.FileSystem

	$ZipName = "$Repo_latest.zip"
	$Json = Invoke-WebRequest -Uri "https://api.github.com/repos/$Owner/$Repo/releases/latest"

	# get the name of the asset (assuming only one and its a zip) 
	if ($Json -match '"name"\s*:\s*"([^"]+?\.zip)"') {
		$ZipName = $matches[1]	
	}

	$SavePath = Join-Path -Path $RootDir -ChildPath $ZipName

	# get the location of the asset, download and extract
	if ($Json -match '"browser_download_url"\s*:\s*"(http[^"]+?)"') {
		(New-Object Net.WebClient).DownloadFile($matches[1], $SavePath)
		[System.IO.Compression.ZipFile]::ExtractToDirectory($SavePath, $RootDir)
	}
}


