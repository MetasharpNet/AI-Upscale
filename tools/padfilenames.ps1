param (
    [Parameter(Mandatory=$true)]
    [string]$FolderPath
)

#$FolderPath = "..\debugfolder"

Set-Location -Path $FolderPath

# Get the list of files in the folder
$files = Get-ChildItem '.'

# Iterate through each file
foreach ($file in $files) {
    # Check if the file name contains a number
    if ($file.Name -match '\d') {

        $newFileName = $file.Name

        # Get the numbers from the original file name
        $matches = $file.Name | Select-String -Pattern "\d+" -AllMatches

        $numberMatches = $matches.Matches | ForEach-Object {
                $number = $_.Value.PadLeft(4, '0')
                $startIndex = $_.Index
                $endIndex = $startIndex + $_.Length
                [PSCustomObject]@{
                    Number = $number
                    StartIndex = $startIndex
                    EndIndex = $endIndex
            }
        }

        $offset = 0
        foreach ($match in $numberMatches) {
            $startIndex = $match.StartIndex + $offset
            $endIndex = $match.EndIndex + $offset
            $number = $match.Number
            $newFileName = $newFileName.Substring(0, $startIndex) + $number + $newFileName.Substring($endIndex)
            $offset += $match.Number.Length - $match.EndIndex + $match.StartIndex
        }

        # Rename the file
        Rename-Item -LiteralPath "$file" -NewName "SFDOGSDI_$newFileName"

    }
}

# Get the list of files in the folder
$files = Get-ChildItem "." | Sort-Object -Property Name

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
    Rename-Item -LiteralPath "$file" -NewName "$newFileName"
}
