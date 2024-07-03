param (
    [string]$filepath,
	
	# "QTGMC", "Decomb", "JustResize"
	[string]$mode = "QTGMC",
	# "None", "BFF" for VHS, "TFF" for DVD
	[string]$assumeMode = "None",
	# "None", "Bilinear", "Spline64" for a small sharpening
	[string]$resizeAlgo = "None",
	# specific height
	[int]$y = 0,
	# specific width
	[int]$x = 0,
	# "None", "Auto", "Manual"
	[string]$crop = "None",
	# specific pixel value (used only for Manual)
	[int]$cropTop = 0,
	# specific pixel value (used only for Manual)
	[int]$cropBottom = 0,
	# specific pixel value (used only for Manual)
	[int]$cropLeft = 0,
	# specific pixel value (used only for Manual)
	[int]$cropRight = 0
)

# Function to round to the nearest multiple of 4
function RoundToNearestMultipleOfFour($number)
{
    return [Math]::Round($number / 4) * 4
}

# Extract Video Info
$mediaInfoOutput = & .\tools\mediainfo.exe "--Output=Video;%Width%-%Height%-%DisplayAspectRatio%;%Matrix_coefficients%;%ScanType%" $filepath
$mediaInfoOutputSplit = $mediaInfoOutput -split "-"
$videoX = [int]$mediaInfoOutputSplit[0]
$videoY = [int]$mediaInfoOutputSplit[1]
$aspectRatio = [decimal]$mediaInfoOutputSplit[2]
$matrixCoefficients = $mediaInfoOutputSplit[3]
$scanType = $mediaInfoOutputSplit[4]

# Determine the correct matrix setting for ConvertToYV12 based on matrix coefficients
$matrixSetting = "Rec601"
switch -Regex ($matrixCoefficients)
{
    "BT\.601"  { $matrixSetting = "Rec601"  }
    "BT\.709"  { $matrixSetting = "Rec709"  }
    "BT\.2020" { $matrixSetting = "Rec2020" }
    Default    { $matrixSetting = "Rec601"  } # Default to Rec601 if unsure
}
# Interlacing
$interlaced = $false
if ($scanType -eq "Interlaced")
{
    $interlaced = $true
}

# Initial Resize to get a resolution with multiples of 4
$initialResize = $false
$initialVideoX = RoundToNearestMultipleOfFour $videoX
$initialVideoY = RoundToNearestMultipleOfFour $videoY
if ($initialVideoX -ne $videoX -or $initialVideoY -ne $videoY)
{
	$initialResize = $true
}

# Resize
$videoX2 = [int]($videoY * $aspectRatio)
if ($videoX2 -ne $videoX)
{
	if ($resizeAlgo -ne "Bilinear" -and $resizeAlgo -ne "Spline64")
	{
        $resizeAlgo = "Bilinear"
	}
	$videoX =$videoX2
}
if ($y -gt 0)
{
	if ($x -gt 0)
	{
		$videoY = $y
		$videoX = $x
	}
	else
	{
		$videoX = [Math]::Floor($y * $videoX / $videoY)
		$videoY = $y
	}
	if ($resizeAlgo -ne "Bilinear" -and $resizeAlgo -ne "Spline64")
	{
        $resizeAlgo = "Bilinear"
	}
}
elseif ($x -gt 0)
{
	$videoY = [Math]::Floor($x * $videoY / $videoX)
	$videoX = $x
	if ($resizeAlgo -ne "Bilinear" -and $resizeAlgo -ne "Spline64")
	{
        $resizeAlgo = "Bilinear"
	}
}
$videoX = RoundToNearestMultipleOfFour $videoX
$videoY = RoundToNearestMultipleOfFour $videoY

# Get CPU information
$logicalCores = (Get-WmiObject -Class Win32_ComputerSystem).NumberOfLogicalProcessors
$physicalCores = (Get-WmiObject -Class Win32_Processor).NumberOfCores


# Calculate values
$ediThreads = [Math]::Floor($physicalCores / 2)
$prefetchLogicalCores = $logicalCores - 2

# Create the Avisynth script content
$content = @"
FFmpegSource2("$filepath", atrack=-1)

"@

if ($initialResize -eq $true)
{
	$content = $content + @"
BilinearResize($initialVideoX,$initialVideoY)

"@
}

$content = $content + @"
ConvertBits(8)
ConvertToYV12(matrix="$matrixSetting", interlaced=$interlaced)
if ("$assumeMode" == "TFF")
{
    AssumeTFF() # DVD sources
}
else if ("$assumeMode" == "BFF")
{
    AssumeBFF() # VHS sources
}
if ("$mode" == "QTGMC")
{
	SetFilterMTMode("QTGMC", 2)
	QTGMC(preset="Slower", EdiThreads=$ediThreads) # physical cores /2
}
else if ("$mode" == "Decomb")
{
    FieldDeinterlace(blend=false) # without Bob
}
else if ("$mode" == "Eddi2")
{
    TDeint(edeint=SeparateFields().SelectEven().EEDI2())
}
if ("$resizeAlgo" == "Bilinear")
{
    BilinearResize($videoX,$videoY)
}
else if ("$resizeAlgo" == "Spline64")
{
	Spline64Resize($videoX,$videoY) # sharpens a bit
}
Prefetch($prefetchLogicalCores) # logical cores -2

"@

if ($crop -eq "Auto")
{
	$content = $content + @"
Robocrop()

"@
}
elseif ($crop -eq "Manual")
{
	$content = $content + @"
Robocrop($cropLeft, $cropTop, -$cropRight, -$cropBottom)

"@
}

# Write the content to deinterlace.avs file
Set-Content -Path "deinterlace.avs" -Value $content
