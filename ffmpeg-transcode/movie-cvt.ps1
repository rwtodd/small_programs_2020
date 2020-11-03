<#
.Synopsis
This is a script to remove some tedium from the process of transcoding
DVDs to H.265+libopus MKV files.

.Description
ffmpeg and ffprobe are used in this process

.Parameter movie
The movie to transcode

.Example
movie-cvt.ps1 -movie my-file.mkv
#>
Param (
   [Parameter(Mandatory=$true)][System.IO.FileInfo] $movie
)

$probe = "C:\Program Files\ffmpeg-20200831-4a11a6f-win64-static\bin\ffprobe.exe"
$mpeg = "C:\Program Files\ffmpeg-20200831-4a11a6f-win64-static\bin\ffmpeg.exe"

& $probe -i $movie
$result = $movie.BaseName + "_small.mkv"
echo "Writing result to $result"

$streams = "0 " + (Read-Host -Prompt "Which streams to map? (0 is a given) ")
$streams = ($streams -split '\s+') | ForEach-Object -Process { "-map 0:" + $_ }

$cmd = "& `"$mpeg`" -i `"$movie`" -c:s copy -c:v libx265 -crf 23 -c:a libopus -b:a 128k $streams `"$result`""
echo $cmd
Invoke-Expression $cmd
