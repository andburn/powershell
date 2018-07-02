#Requires -Version 3.0

Function DownloadZipAndExtract {
Param (
	[string]$RootDir,
	[string]$SavePath,
	[string]$URL
)
	Add-Type -AssemblyName System.IO.Compression.FileSystem

	(New-Object Net.WebClient).DownloadFile($URL, $SavePath)
	[System.IO.Compression.ZipFile]::ExtractToDirectory($SavePath, $RootDir)
}

Function GetLatestRelease {
Param(
	[string]$RootDir,
	[string]$Owner,
	[string]$Repo,
	[switch]$Scrape
)

	# use TLS 1.2, default is TLS 1.0
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	$ZipName = "$($Repo)_latest.zip"
	$Dir = Resolve-Path $RootDir

	If ($Scrape) {
		# scrape the html (avoids rate limit in cloud)
		$SavePath = Join-Path -Path $Dir -ChildPath $ZipName
		$html = Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/$Owner/$Repo/releases/latest"
		$url = ($html.Links | Where { $_.href -like '*releases/download*' }).href
		DownloadZipAndExtract $Dir $SavePath "https://github.com$url"
	} else {
		# use github api
		$Json = (Invoke-WebRequest -UseBasicParsing -Uri "https://api.github.com/repos/$Owner/$Repo/releases/latest").Content

		# get the name of the asset (assuming only one and its a zip)
		If ($Json -match '"name"\s*:\s*"([^"]+?\.zip)"') {
			$ZipName = $matches[1]
		}
		$SavePath = Join-Path -Path $Dir -ChildPath $ZipName

		# get the location of the asset, download and extract
		If ($Json -match '"browser_download_url"\s*:\s*"(http[^"]+?)"') {
			DownloadZipAndExtract $Dir $SavePath $matches[1]
		}
	}
}
