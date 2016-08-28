$ScriptPath = Split-Path $Profile | Join-Path -ChildPath 'Scripts'
New-Alias NUnit $ScriptPath\Invoke-NUnitOnProject.ps1
New-Alias OpenCover $ScriptPath\Invoke-OpenCoverOnProject.ps1
New-Alias python64 $env:Dev\Python\python.exe