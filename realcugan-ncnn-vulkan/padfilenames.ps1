param (
    [Parameter(Mandatory=$true)]
    [string]$FolderPath
)

# Get the list of files in the folder
$files = Get-ChildItem $FolderPath

# Iterate through each file
foreach ($file in $files) {
    # Check if the file name contains a number
    if ($file.Name -match '\d') {
        # Extract the file extension
        $extension = $file.Extension

        # Remove the extension from the original file name
        $baseName = $file.Name -replace '\d', ''

        # Get the number from the original file name
        $number = $file.Name -replace '\D', ''

        # Pad the number to four characters
        $paddedNumber = $number.PadLeft(4, '0')

        # Create the new file name by combining the base name and padded number
        $newFileName = 'SFDOGSDIFGSDOFGISDOFG' + $paddedNumber + $file.Name + $extension

        # Rename the file
        Rename-Item -Path $file.FullName -NewName $newFileName
    }
}

# Get the list of files in the folder
$files = Get-ChildItem $FolderPath | Sort-Object -Property Name

# Calculate the number of digits required for padding
$paddingDigits = $files.Count.ToString().Length

# Iterate through each file
for ($i = 0; $i -lt $files.Count; $i++) {
    $file = $files[$i]

    # Extract the file extension
    $extension = $file.Extension

    # Pad the index with leading zeros
    $paddedIndex = ($i + 1).ToString().PadLeft($paddingDigits, '0')

    # Create the new file name
    $newFileName = $paddedIndex + $extension

    # Rename the file
    Rename-Item -Path $file.FullName -NewName $newFileName
}