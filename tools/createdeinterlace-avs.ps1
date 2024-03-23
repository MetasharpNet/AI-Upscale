param (
    [string]$filename
)

$mediaInfoOutput = & .\tools\mediainfo.exe "--Output=Video;%Width%x%Height%" $filename
$x, $y = $mediaInfoOutput.Split("x")
#$x = [Math]::Floor(1080 * $x / $y)
#$y = 1080

# Get CPU information
$logicalCores = (Get-WmiObject -Class Win32_ComputerSystem).NumberOfLogicalProcessors
$physicalCores = (Get-WmiObject -Class Win32_Processor).NumberOfCores

# Calculate values
$ediThreads = [Math]::Floor($physicalCores / 2)
$prefetchlogicalcores = $logicalCores - 2

# Create the Avisynth script content
$content = @"
SetFilterMTMode("QTGMC", 2)
FFmpegSource2("$filename", atrack=-1)
ConvertToYV12()
AssumeTFF() # DVD sources
#AssumeBFF() # VHS sources
QTGMC(preset="Slower", EdiThreads=$ediThreads) # physical cores /2
#BilinearResize($x,$y) # resize
#Spline64Resize($x,$y) # resize + sharpens a bit
Prefetch($prefetchlogicalcores) # logical cores -2
"@

# Write the content to deinterlace.avs file
Set-Content -Path "deinterlace.avs" -Value $content