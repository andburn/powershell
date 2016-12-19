$ScriptPath = Split-Path $Profile | Join-Path -ChildPath 'Scripts'
# .NET
New-Alias NUnit $ScriptPath\Invoke-NUnitOnProject.ps1
New-Alias OpenCover $ScriptPath\Invoke-OpenCoverOnProject.ps1
New-Alias BuildProj $ScriptPath\Invoke-MSBuildOnProject.ps1
# Git
New-Alias CommitDate $ScriptPath\Git-CommitWithDate.ps1
# Misc
New-Alias npp $env:ProgramFilesX86\Notepad++\notepad++.exe
