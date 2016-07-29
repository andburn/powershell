Function GetChildItemsRegex {
Param(
    [string]$Path, 
    [string]$Regex,
    [switch]$Recurse
)

    (Get-ChildItem -Path $Path -Recurse:$Recurse | Where { $_.FullName -match $Regex }).FullName
}
