. (Resolve-Path "$env:LOCALAPPDATA\GitHub\shell.ps1")
. $env:github_posh_git\profile.example.ps1

# custom profile
function global:prompt {
    $realLASTEXITCODE = $LASTEXITCODE
	
	$global:GitPromptSettings.EnableWindowTitle = " "
	
	$CurrentPath = $pwd.ProviderPath.Split("\")
	$PathLength = $CurrentPath.length
	
    # Reset color, which can be messed up by Enable-GitColors
    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor

	Write-Host("")
    Write-Host($pwd.ProviderPath) -nonewline -foregroundcolor Green

    Write-VcsStatus
	
    $global:LASTEXITCODE = $realLASTEXITCODE
    return "`n$> "
}