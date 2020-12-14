<#
.Synopsis
Then, convert the flac files in the current directory to opus.

.Description
opusenc is used to convert the flac files.  The default bitrate is 256.  The files
are converted in parallel, three at a time.

.Parameter BitRate
The output bitrate (default 256).

.Example
flac-to-opus.ps1 -BitRate 256
#>
Param(
    [int]$BitRate = 256
)

$oe = "C:\Program Files\ffmpeg-20200831-4a11a6f-win64-static\bin\opusenc.exe"

$oldSize = (get-childitem *.flac | measure-object Length -Sum).Sum
get-childitem *.flac | ForEach-Object -Parallel {
    Write-Host "Converting $_" 
    & $Using:oe --quiet --bitrate $Using:BitRate $_ ($_.BaseName + ".opus")
    remove-item -LiteralPath $_
} -ThrottleLimit 3

$newSize = (get-childitem *.opus | measure-object Length -Sum).Sum
Write-Host "Size is now $(100*$newSize/$oldSize)% of the original size."
