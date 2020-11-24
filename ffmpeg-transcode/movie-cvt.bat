@echo off
REM a script to facilitate move conversion

setlocal enabledelayedexpansion

REM set the locations of the tools
set probe="C:\Program Files\ffmpeg-20200831-4a11a6f-win64-static\bin\ffprobe.exe"
set mpeg="C:\Program Files\ffmpeg-20200831-4a11a6f-win64-static\bin\ffmpeg.exe"

REM parse the arugments
:args
if /I "%1" == "/?" goto help 
if /I "%1" == "/a" (set streams=-map 0 & shift & goto args)
if /I "%1" == "/d" (set mix=-ac 2 & shift & goto args)

set movie=%1
set result=%~n1_small.mkv
if "%movie%" == "" goto help

if "%streams%" == "" (
  echo %probe% -i %movie%
  set /P maplist="Which streams to use (0 is a given)? "
  echo !maplist! is the maplist
  for %%m in (0 !maplist!) do (
     set streams=!streams! -map 0:%%m
  )
)

%mpeg% -i %movie%  -c:s copy -c:v libx265 -crf 23 -c:a libopus -b:a 128k %streams% %mix% %result%

endlocal
goto :eof

:help 
  echo This script transcodes a movie to x265+opus MKV
  echo.
  echo Usage: %~n0 [/A] [/D] input.mkv
  echo    /A:       map all streams (don't ask for input)
  echo    /D:       mix down 5.1 audio to stereo 
  echo.

