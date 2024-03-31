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
	[int]$x = 0
)

# Extract Video Info
$mediaInfoOutput = & .\tools\mediainfo.exe "--Output=Video;%Width%-%Height%-%DisplayAspectRatio%" $filepath
$mediaInfoOutputSplit = $mediaInfoOutput -split "-"
$videoX = [int]$mediaInfoOutputSplit[0]
$videoY = [int]$mediaInfoOutputSplit[1]
$aspectRatio = [decimal]$mediaInfoOutputSplit[2]

# Resize
$videoX2 = [int]($videoY * $aspectRatio)
if ($videoX2 -ne $videoX)
{
	if ($resizeAlgo -ne "Bilinear" -and $resizeAlgo -ne "Spline64")
	{
        $resizeAlgo = "Bilinear"
	}
	$videoX = $videoX2
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

# Get CPU information
$logicalCores = (Get-WmiObject -Class Win32_ComputerSystem).NumberOfLogicalProcessors
$physicalCores = (Get-WmiObject -Class Win32_Processor).NumberOfCores


# Calculate values
$ediThreads = [Math]::Floor($physicalCores / 2)
$prefetchLogicalCores = $logicalCores - 2

# Create the Avisynth script content
$content = @"
FFmpegSource2("$filepath", atrack=-1)
ConvertToYV12()
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

# Write the content to deinterlace.avs file
Set-Content -Path "deinterlace.avs" -Value $content