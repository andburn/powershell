$nl = [Environment]::NewLine

Write-Host -ForegroundColor Green "Checking for Git Repos..."

$top_level = Get-ChildItem -Force -Directory
if ($top_level -eq $null) {
	Write-Host -ForegroundColor Red "No git repositories at this location"
	Return
}

$git_dirs = ($top_level.GetDirectories() | Where-Object Name -EQ '.git').Parent
if ($git_dirs -eq $null) {
	Write-Host -ForegroundColor Red "No git repositories at this location"
	Return
}

foreach ($d in $git_dirs) {
	# change to directory containing .git
	cd $d
	# returns a string array
	$git_info = git status 2>&1
	if ($git_info -match "nothing to commit") {
		Write-Host -NoNewline -ForegroundColor DarkGreen "$($d.Name) "
		$git_pull = git pull 2>&1
		if ($git_pull -match "up\-to\-date") {
			Write-Host -ForegroundColor Green "[up to date]"
		} elseif ($git_pull -match "conflict") {
			Write-Host -ForegroundColor Red "[merge conflict]"
		} else {
			Write-Host -ForegroundColor Yellow "[pull ok]"
		}
	} else {
		Write-Host -NoNewline -ForegroundColor Cyan "$($d.Name)"
		Write-Host " [local changes]"
	}
	# change back up to root directory
	cd ..
}
# blank line
Write-Host ""
