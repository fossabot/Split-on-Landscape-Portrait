<# 
 .Synopsis
  Using ImageMagick split pictures in -FolderPath on landscape and portrait oriented.
  
 .Description
  Puts images with landscape orientation into "landscape" subfolder and with portrait orientation into "portrait" subfolder

 .Parameter FolderPath
  Path to a folder containing images to split

 .Parameter ShowProgress
  Whether the show progress indicator should be shown.

 .Example
  # Splits images in "C:\My Images" folder
  split_on_landscape_portraits.ps1 -FolderPath "C:\My Images"

  .Link
  https://github.com/nikolay-borzov/Split-on-Landscape-Portrait
  http://ubuntuforums.org/showthread.php?t=817969
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$FolderPath,

    [Bool]$ShowProgress = $True
)

# add functions
. "$PSScriptRoot\GetDestination.ps1"

$PORTRAIT_FOLDER = "portrait"
$LANDSCAPE_FOLDER = "landscape"

$portraitPath = Get-Destination $PORTRAIT_FOLDER $FolderPath
$landscapePath = Get-Destination $LANDSCAPE_FOLDER $FolderPath

$landscapeCount = 0
$portraitCount = 0
$skippedtCount = 0

$fileNames = Get-ChildItem -Path $FolderPath\* -Include *.gif, *.jpg, *.png, *.jpeg | ?{ $_.PSIsContainer-eq $False } | % { $_.FullName }
$i = 0
$filesCount = $fileNames.Length

foreach($fileName in $fileNames) 
{
  if($ShowProgress) 
  {
    $i++
    [int]$percentProcessed = ($i / $filesCount) * 100
    Write-Progress -Activity "Processing image ($i/$filesCount) at $FolderPath" -Status "$percentProcessed%" -PercentComplete ($percentProcessed)
  }

  $widthRaw = identify -format %w $fileName
  $heightRaw = identify -format %h $fileName

  $width = $widthRaw -as [int]
  $height = $heightRaw -as [int]

  # skip image which dimensions for some reason are bigger than int
  if($width-eq $null -or $height -eq $null) 
  {
    $skippedtCount++
    continue
  }

  if($height -lt $width) 
  { 
    $destination = $landscapePath
    $landscapeCount++
  }
  else 
  {
    $destination = $portraitPath
    $portraitCount++
  }

  Move-Item -LiteralPath $fileName -Destination $destination -Force
}

$message = "$FolderPath"
$message += "`n$filesCount images total"
$message += "`nLansdcape: $landscapeCount"
$message += "`nPortrait: $portraitCount"
$message += "`nSkipped: $skippedtCount"

Write-Host $message
