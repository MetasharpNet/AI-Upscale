param (
    [Parameter(Mandatory=$true)]
    [string]$SourceFilePath,
    
    [Parameter(Mandatory=$true)]
    [string]$DestinationFolder
)

function Move-FilesRecursively {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Folder,

        [Parameter(Mandatory=$true)]
        [string]$DestinationFolder
    )

    $files = Get-ChildItem -LiteralPath $Folder -File
    foreach ($file in $files) {
        $newFilePath = Join-Path $DestinationFolder $file.Name
        Move-Item -LiteralPath $file.FullName -Destination $newFilePath -Force
    }

    $subFolders = Get-ChildItem -Path $Folder -Directory
    foreach ($subFolder in $subFolders) {
        Move-FilesRecursively -Folder $subFolder.FullName -DestinationFolder $DestinationFolder
    }
}

Move-FilesRecursively -Folder $DestinationFolder -DestinationFolder $DestinationFolder

$subFolders = Get-ChildItem -LiteralPath $DestinationFolder -Directory
foreach ($subFolder in $subFolders) {
    $subFolder = Join-Path $DestinationFolder $subFolder
    Remove-Item -LiteralPath $subFolder -Recurse -Force
}
