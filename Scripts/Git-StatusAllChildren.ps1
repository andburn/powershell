#Requires -Version 3.0

Param(
	[string]$Directory,
    [switch]$Verbose = $False
)

if (-not $Directory) {
    $Directory = $pwd
}

$nl = [Environment]::NewLine

Write-Host -NoNewLine "Searching $Directory for git repos..."

$repos = Get-ChildItem $Directory `
    -Attributes Directory,Directory+Hidden `
    -ErrorAction SilentlyContinue `
    -Include ".git" -Recurse
    
Write-Host $repos.Length "Found.$nl"

$unstaged = 0
foreach($d in $repos) {
    $parent = $d.Parent.FullName
	cd $parent
	$status = git status 2>&1
    if ($status -match "nothing to commit") {
        if ($Verbose) {
            Write-Host -ForegroundColor DarkGreen $parent
        }
    } else {
        Write-Host -ForegroundColor Red $parent
        $unstaged++
    }
}

cd $Directory

if ($unstaged -gt 0) {
    Write-Host -ForegroundColor Red "$nl$unstaged repos with unstaged changes"
} else {
    Write-Host -ForegroundColor "No unstaged changes found"
}
  
