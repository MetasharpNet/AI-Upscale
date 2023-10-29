param (
    [string]$sourceFolder
)

if (-not (Test-Path $sourceFolder)) {
    Write-Host "The specified folder does not exist."
    exit 1
}

Get-ChildItem -File -Path $sourceFolder -Recurse | ForEach-Object {
    $newName = $_.Name -replace '\^', '_'
    $newName = $newName -replace '\[', '_'
    $newName = $newName -replace '\]', '_'
    $newPath = Join-Path -Path $_.DirectoryName -ChildPath $newName
    Rename-Item -LiteralPath $_.FullName -NewName $newName
}