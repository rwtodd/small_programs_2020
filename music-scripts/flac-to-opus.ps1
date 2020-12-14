# convert the flac files in the current directory to opus files at
# bitrate 256

$oe = "C:\Program Files\ffmpeg-20200831-4a11a6f-win64-static\bin\opusenc.exe"
$bitrate = 256

get-childitem *.flac | %{ 
   Start-ThreadJob -ScriptBlock {
       param($opus,$brate,$infile)
       & $opus --bitrate $brate $infile ($infile.BaseName + ".opus")
       remove-item -LiteralPath $infile
   } -ThrottleLimit 3 -Name $_  -ArgumentList @($oe,$bitrate,$_) 
}

