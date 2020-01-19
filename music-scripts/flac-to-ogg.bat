@echo off
setlocal 

set ffmpeg="C:\Program Files\ffmpeg-4.1-win64-static\bin\ffmpeg.exe"
set vorbisq=8

FOR %%x IN (%*) DO (
  echo %%~nxx to ogg
  if not exist "%%~nx.ogg" %ffmpeg% -nostats -loglevel error ^
     -i "%%x" -vn "-c:a" libvorbis "-q:a" %vorbisq% "%%~nx.ogg"
)

