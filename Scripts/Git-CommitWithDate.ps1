#Requires -Version 3.0

Param(
	[string]$Message,
	[string]$Date,
	[string]$Time	
)

Function GetRandomTime {
	$hour = Get-Random -Minimum 9 -Maximum 24
	$mins = Get-Random -Maximum 60
	$secs = Get-Random -Maximum 60
	Return "{0}:{1}:{2}" -f $hour.ToString("D2"), $mins.ToString("D2"), $secs.ToString("D2")
}

Function GetUTCOffset {
	Return Get-Date -UFormat "%Z00"
}

if (-not $Message) {
	Write-Host -ForegroundColor Red "A commit message is required"
    Return
}

$CommitDate = Get-Date -UFormat "%Y-%m-%d %T %Z00"

if ($Date) {
	$CommitDate = $Date
	if ($Time) {
		$CommitDate += " $Time"
	} else {
		$CommitDate += " $(GetRandomTime)"
	}
	$CommitDate += " $(GetUTCOffset)"
}

# run command
$env:GIT_COMMITTER_DATE="`"$CommitDate`""
git commit --date="`"$CommitDate`"" -m "`"$Message`""
# clear env variable
$env:GIT_COMMITTER_DATE=""
