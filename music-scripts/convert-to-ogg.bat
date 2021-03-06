@echo off
setlocal ENABLEDELAYEDEXPANSION

REM set up some configuration
set sevenZip="C:\Program Files\7-Zip\7z.exe"
set ffmpeg="C:\Program Files\ffmpeg-4.1-win64-static\bin\ffmpeg.exe"
set vorbisq=8

set tgtBase=C:\Users\richa\Music
set srcBase=C:\Users\richa\OneDrive\DataFiles\Audio
set tmpDir=%TEMP%\rwt-audio
set defaultCover=C:\Users\richa\OneDrive\DataFiles\Audio\cover.jpg

:args
if /I "%1" == "/?" goto help 
if /I "%1" == "/nz" (set skipZip=1 & shift & goto args)
if /I "%1" == "/vq" (set vorbisq=%2 & shift & shift & goto args)

set src=%~f1
call set relSrc=%%src:%srcBase%\=%%
REM if the C: drive address didn't work, try the H: drive
if [%relSrc%] == [%src%] (
   set srcBase=H:\OneDrive\DataFiles\Audio
   call set relSrc=%%src:!srcBase!\=%%
)

REM *****************************************************************
REM SEt up the src and tgt directories
REM *****************************************************************
if not exist "%src%" (echo Can't find input file ^<%src%^> & goto error)
if /I NOT "%src:~-4%" == ".zip" (echo input is not a zip file! & goto error)
if [%relSrc%] == [%src%] (echo zipfile must be in %srcBase% & goto error)
set relSrc=%relSrc:~0,-4%
set tgt=%tgtBase%\%relSrc%

echo Putting the album in %tgt%
if exist %tgt% (
  echo Target directory already exists^^!
  echo.
  choice /C DLQ /N /M "(D)elete existing files, (L)eave them, or (Q)uit? "
  if !ERRORLEVEL! EQU 0 (echo ERORR! & goto error)
  if !ERRORLEVEL! EQU 3 goto error
  if !ERRORLEVEL! EQU 1 del/S/Q "%tgt%\*.*"
) else (
  mkdir "%tgt%" 2>nul
)
  
REM clear out the temp dir and the target dir
c:
mkdir "%tmpDir%" 2>nul
cd "%tmpDir%"

if not defined skipZip (
  del/S/Q *.*
  %sevenZip% e "%src%"
)

REM *****************************************************************
REM Transfer the cover, or a default cover
REM *****************************************************************
if exist cover.jpg (
  move cover.jpg "%tgt%"
) else (
  copy "%defaultCover%" "%tgt%"
)

SETLOCAL DisableDelayedExpansion
REM *****************************************************************
REM Transfer any mp3, m4a, opus, or ogg files
REM *****************************************************************
FOR %%x IN (*.mp3 *.m4a *.opus *.ogg) DO move "%%x" "%tgt%" 

REM *****************************************************************
REM Convert FLAC to ogg
REM *****************************************************************
FOR %%x IN (*.flac) DO (
  echo Converting %%~nxx to ogg at -q:a %vorbisq%
  %ffmpeg% -nostats -loglevel error ^
     -i "%%x" -vn "-c:a" libvorbis "-q:a" %vorbisq% "%tgt%\%%~nx.ogg"
  del "%%x"
)
ENDLOCAL

echo Done^^!
goto :eof

:help 
  echo This script unzips an audio archive, converts any flac to ogg,
  echo and leaves the result in the ~\Music folder.
  echo.
  echo Usage: %~n0 [/nz] [/vq quality] zipfile
  echo    /NZ:  skip the unzipping stage (No Zip) 
  echo    /VQ quality:  convert at -q `quality` instead of default 8 
:error
  exit /b 2

