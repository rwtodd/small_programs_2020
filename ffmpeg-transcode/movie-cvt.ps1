<#
.Synopsis
This is a script to remove some tedium from the process of transcoding
DVDs to H.265+libopus MKV files.

.Description
ffmpeg and ffprobe are used in this process. The current directory is always the
output location.

.Parameter Path 
The movie to transcode
.Parameter MixDown
Mix down 5.1 surround sound to Stereo
.Parameter MapAll
Map all the input streams

.Example
movie-cvt.ps1 -movie my-file.mkv
.Example
gci ..\*.mkv | movie-cvt.ps1 -mapall
#>
Param (
   [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
   [ValidatePattern('\.mkv$')]
   [string] $Path,
   [Switch] $MixDown,
   [Switch] $MapAll
)
BEGIN {
   $probe = "C:\Program Files\ffmpeg-20200831-4a11a6f-win64-static\bin\ffprobe.exe"
   $mpeg = "C:\Program Files\ffmpeg-20200831-4a11a6f-win64-static\bin\ffmpeg.exe"

   $mix = ""
   if ($MixDown) {
      $mix = "-ac 2"
   }

}
PROCESS {
   $movie = Get-Item $Path   
   Write-Verbose "Input movie is $movie"
   $result = $movie.BaseName + "_small.mkv"
   Write-Verbose "Writing result to $result"

   $streams = "-map 0"
   if (-not $MapAll) {
      & $probe -i $movie
      $streams = "0 " + (Read-Host -Prompt "Which streams to map? (0 is a given) ")
      $streams = ($streams.Trim() -split '\s+') | ForEach-Object -Process { "-map 0:" + $_ }
   }

   $cmd = "& `"$mpeg`" -i `"$movie`" -c:s copy -c:v libx265 -crf 23 -c:a libopus -b:a 128k $streams $mix `"$result`""
   Write-Verbose $cmd
   $cmd | Start-ThreadJob { Invoke-Expression $input } -ThrottleLimit 1 -Name $result
}
END {}
