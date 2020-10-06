<#
.Synopsis
Open the provided ZIP file into a directory of the same name in the current
directory.  Then, convert the flac files in the current directory to opus
files at $bitrate (default 256)

.Description
opusenc is used to convert the flac files.

.Parameter zip
The zip file to decompress
.Parameter bitrate
The output bitrate (default 256).

.Example
zip-to-opus.ps1 -zip a_zipfile.zip -bitrate 256
#>
Param (
   [Parameter(Mandatory=$true)][System.IO.FileInfo] $zip,
   [Int32] $bitrate = 256
)

$oe = "C:\Program Files\ffmpeg-20200831-4a11a6f-win64-static\bin\opusenc.exe"
$album = $zip.BaseName

mkdir $album | Out-Null
push-location $album | Out-Null
Expand-Archive -LiteralPath $zip -DestinationPath .
get-childitem *.flac | %{
    echo $_.Name
    & $oe --quiet --bitrate $bitrate $_ ($_ -replace 'flac$','opus')
    remove-item -LiteralPath $_
}
pop-location
