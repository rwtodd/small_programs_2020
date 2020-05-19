#!/bin/bash
################################################################
# A script to help me: 
#  (1) unzip an archived album into place, and
#  (2) convert all the FLAC files it may have to OGG VORBIS
################################################################

shopt -s nullglob

FFMPEG="/mnt/c/Program Files/ffmpeg-4.1-win64-static/bin/ffmpeg.exe"
# FFMPEG=ffmpeg
QUALITY=8
INPLACE=n
KEEP=n

function usage {
  echo "Usage: $0 [-i] [-k] [-q quality] [zip file]" 1>&2
  echo "   -i       convert current directory files (no unzipping)" 1>&2
  echo "   -k       keep the flac files" 1>&2
  echo "   -q num   use 'num' for quality in vorbis encoder" 1>&2
}


function tovorbis {
  local fn=$1
  echo "Converting $fn to ogg at -q:a $QUALITY" 1>&2
  "$FFMPEG" -nostats -loglevel error \
     -i "$fn" -vn "-c:a" libvorbis "-q:a" $QUALITY "${fn%.*}.ogg" \
   || exit 1
   if [ "$KEEP" == "n" ] ; then rm "$fn" ; fi
}

while getopts "hiq:" options
do
  case "${options}" in
    h) usage ; exit ;;
    i) INPLACE=y ;;
    k) KEEP=y ;;
    q) QUALITY=$OPTARG ;;
  esac
done

if [ "$INPLACE" == "y" ]
then
  for flac in *.flac ; do tovorbis "$flac" ; done
  exit
fi

if [ "$1" == "" ] ; then usage ; exit 1 ; fi

echo "Processing $1..."
dirname=$(basename $1 .zip)
if [ -d "$dirname" ]
then
  echo "$dirname already exists!" 2>&1
  echo "(D)elete, (L)eave them, or (Q)uit?" 2>&1
  read choice
  case "$choice" in
    d|D) rm -r "$dirname" ;;
    l|L) ;;
    q|Q) exit ;;
  esac
fi

mkdir -p "$dirname"
unzip -qoj $1 -d "$dirname" 
(
  cd $dirname
  for flac in *.flac ; do tovorbis "$flac" ; done
)

