$ScriptPath = Split-Path $Profile | Join-Path -ChildPath 'Scripts'
New-Alias Run-Nunit $ScriptPath\dev_run_nunit.ps1