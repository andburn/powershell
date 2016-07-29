$ScriptPath = Split-Path $Profile | Join-Path -ChildPath 'Scripts'
New-Alias Run-NUnit $ScriptPath\Run-NUnitOnProject.ps1