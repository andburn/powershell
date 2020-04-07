$ScriptPath = Split-Path $Profile | Join-Path -ChildPath 'Scripts'
# Import PoshGit
Import-Module posh-git
# Disable error ping
Set-PSReadlineOption -BellStyle Visual
# Aliases
# .NET
New-Alias NUnit $ScriptPath\Invoke-NUnitOnProject.ps1
New-Alias OpenCover $ScriptPath\Invoke-OpenCoverOnProject.ps1
New-Alias BuildProj $ScriptPath\Invoke-MSBuildOnProject.ps1
# Git
New-Alias CommitDate $ScriptPath\Git-CommitWithDate.ps1
# Misc
New-Alias npp $env:ProgramFilesX86\Notepad++\notepad++.exe
New-Alias hdt $ScriptPath\Invoke-DeckTracker.ps1
New-Alias hdt-plugin $ScriptPath\Copy-DeckTrackerPlugin.ps1
New-Alias hash $ScriptPath\Utils-Checksum.ps1
# Functions
Function md5sum([string]$file) { & $ScriptPath\Utils-Checksum.ps1 -File $file -Algorithm MD5 }
Function sha1sum([string]$file) { & $ScriptPath\Utils-Checksum.ps1 -File $file -Algorithm SHA1 }
Function sha256sum([string]$file) { & $ScriptPath\Utils-Checksum.ps1 -File $file -Algorithm SHA256 }
