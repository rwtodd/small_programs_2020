# convert the flac files in the current directory to opus files at
# $bitrate (default 256)

$oe = "C:\Program Files\ffmpeg-20200831-4a11a6f-win64-static\bin\opusenc.exe"
$bitrate = 256

get-childitem *.flac | %{
    echo $_.Name
    & $oe --quiet --bitrate $bitrate $_ ($_ -replace 'flac$','opus')
    remove-item -LiteralPath $_
}

