Param([string]$RootDir)

Add-Type -AssemblyName System.IO.Compression.FileSystem

$download_file = Join-Path -Path $RootDir -ChildPath 'hdt.zip'
$rename_new = Join-Path -Path $RootDir -ChildPath 'build'
$rename_old = Join-Path -Path $RootDir -ChildPath 'Hearthstone Deck Tracker'

$html = Invoke-WebRequest -Uri 'https://github.com/HearthSim/Hearthstone-Deck-Tracker/releases/latest'
$url = ($html.ParsedHtml.getElementsByTagName('a') | Where { $_.href -like '*releases/download*' }).href.Replace('about:', 'https://github.com')

(New-Object Net.WebClient).DownloadFile($url, $download_file)
[System.IO.Compression.ZipFile]::ExtractToDirectory($download_file, $RootDir)
Rename-Item -NewName $rename_new -Path $rename_old
