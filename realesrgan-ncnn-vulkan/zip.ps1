param (
    [Parameter(Mandatory=$true)]
    [string]$SourceFolder,
    
    [Parameter(Mandatory=$true)]
    [string]$DestinationFilePath
)

if (-not (Test-Path $SourceFolder)) {
    Write-Host "Source folder not found: $SourceFolder"
    exit 1
}

if (-not (Test-Path (Split-Path -Parent $DestinationFilePath))) {
    Write-Host "Destination filepath not found: $(Split-Path -Parent $DestinationFilePath)"
    exit 1
}

# Append ".zip" to the destination path temporarily
$DestinationFilePathAsZip = $DestinationFilePath + ".zip"

# Compress the folder into a ZIP archive
Compress-Archive -Path $SourceFolder\*.* -DestinationPath $DestinationFilePathAsZip -CompressionLevel Optimal

# Create the full path for the final ".cbz" file
$DestinationFolder=Split-Path $DestinationFilePath
$DestinationFilename=Split-Path $DestinationFilePath -Leaf

# Rename the ".zip" file to ".cbz"
Rename-Item -Path $DestinationFilePathAsZip -NewName ($DestinationFilename)
