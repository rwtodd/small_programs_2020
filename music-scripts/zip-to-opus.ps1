<#
.Synopsis
Extract files from a zip archive, and convert flac files to opus.

.Description
opusenc is used to convert the flac files.
The given Zip file is expanded into a directory of the same name as the archive in the current
directory.  Then, all flac files in the new directory are converted to opus
files at the given bit rate (default 256)

.Parameter ZipFile
The zip file to decompress
.Parameter BitRate
The output bitrate (default 256).

.Example
zip-to-opus.ps1 a_zipfile.zip -BitRate 256
#>
Param (
   [Parameter(Position=0,Mandatory=$true)]
   [ValidatePattern("zip$")]
   [string] $ZipFile,
   [Int32] $BitRate = 256
)
$oe = "C:\Program Files\ffmpeg-20200831-4a11a6f-win64-static\bin\opusenc.exe"

$zip = (get-item $ZipFile)
$album = $zip.BaseName

mkdir $album | Out-Null
push-location $album | Out-Null

Expand-Archive -LiteralPath $zip -DestinationPath .
$oldSize = [Math]::Max( (get-childitem . | measure-object Length -Sum).Sum, 1 )

get-childitem *.flac | ForEach-Object -Parallel {
    Write-Host "Converting $($_.Name)" 
    & $Using:oe --quiet --bitrate $Using:BitRate $_ ($_.BaseName + ".opus")
    remove-item -LiteralPath $_
} -ThrottleLimit 3

$newSize = (get-childitem . | measure-object Length -Sum).Sum
Write-Host "Size is now $(100*$newSize/$oldSize)% of the original size."

pop-location
