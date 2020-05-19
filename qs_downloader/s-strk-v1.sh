#!/bin/bash
magick=convert # you might have magick
url_base1='http://www.midimusicadventures.com/qs/digital/ssv1cd/Track0[1-9].mp3'
url_base2='http://www.midimusicadventures.com/qs/digital/ssv1cd/Track[10-19].mp3'

curl --remote-name-all "$url_base1"
curl --remote-name-all "$url_base2"
 
curl 'http://www.midimusicadventures.com/wp-content/uploads/2015/07/SSV1CDCover.jpg' > large_cover.jpg
$magick large_cover.jpg -resize 600x600 cover.jpg
 
# change the single-digit files so they sort properly
for x in Track*.mp3
do
   mv $x "SSV1-$x" 
done
 
mkdir bkup
cp *.mp3 *.jpg bkup

# now fixup the mp3 tags
track_names=(
 [1]="GABRIEL KNIGHT THEME"
"GIRL IN THE TOWER"
"WILLY BEAMISH INTRODUCTION"
"CHERI TART"
"BLACK WIDOW VAMP"
"THE GEDDE ESTATE"
"ICEMAN INTRODUCTION"
"POLICE QUEST 3 INTRODUCTION"
"ERANA’S PEACE"
"COLONEL’S BEQUEST CLOSING THEMES"
"SPACE QUEST 4 INTRODUCTION"
"WIT/ERASMUS’ PRETEST"
"ERANA’S POOL"
"ERANA’S GARDEN"
"BIG BAND LARRY"
"SPACE QUEST 3 INTRODUCTION"
"KING’S QUEST 5 CLOSING MEDLEY"
"ECO QUEST I CLOSING MEDLEY"
"A HERO’S QUEST"
)

odir="Sierra-STrk-V1"
mkdir -p $odir

for id in ${!track_names[*]}
do
  fn=$(printf "SSV1-Track%02d.mp3" $id)
  id3v2 -D $fn 
  id3v2 -t "${track_names[$id]}"  -A "Sierra Soundtracks Vol 1" -y 1998 -a "Sierra" -g 36 -T "$id" $fn
  ffmpeg -i $fn -i cover.jpg -c:a copy -c:v copy -map 0:0 -map 1:0 -id3v2_version 3 \
    -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "$odir/$fn"
done

