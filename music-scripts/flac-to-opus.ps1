# convert the flac files in the current directory to opus files at
# bitrate 256

$oe = "C:\Program Files\ffmpeg-20200831-4a11a6f-win64-static\bin\opusenc.exe"

get-childitem *.flac | %{ 
   Start-ThreadJob -ScriptBlock {
     param($infile)
     opusenc --bitrate 256 $infile ($infile.BaseName + ".opus")
     remove-item -LiteralPath $infile
   } -ThrottleLimit 3 -Name $_  -ArgumentList $_ 
}

