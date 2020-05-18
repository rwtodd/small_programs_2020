#!/bin/bash
magick=convert # you might have magick
url_base1='http://www.midimusicadventures.com/qs/digital/cnicd/CNITrack0[1-9].mp3'
url_base2='http://www.midimusicadventures.com/qs/digital/cnicd/CNITrack10.mp3'
url_base3='http://www.midimusicadventures.com/qs/digital/cnicd/CNITrack11a.mp3'
url_base4='http://www.midimusicadventures.com/qs/digital/cnicd/CNITrack11b.mp3'
url_base5='http://www.midimusicadventures.com/qs/digital/cnicd/CNITrack[12-24].mp3'
url_base6='http://www.midimusicadventures.com/qs/digital/cnicd/CNITrack16b.mp3'

curl --remote-name-all "$url_base1"
curl --remote-name-all "$url_base2"
curl --remote-name-all "$url_base3"
curl --remote-name-all "$url_base4"
curl --remote-name-all "$url_base5"
curl --remote-name-all "$url_base6"

# fix up the file names--they are all over the place!
file_names=(
  [1]='CNITrack01.mp3'
  'CNITrack02.mp3'
  'CNITrack03.mp3'
  'CNITrack04.mp3'
  'CNITrack05.mp3'
  'CNITrack06.mp3'
  'CNITrack07.mp3'
  'CNITrack08.mp3'
  'CNITrack09.mp3'
  'CNITrack10.mp3'
  'CNITrack11a.mp3'
  'CNITrack11b.mp3'
  'CNITrack12.mp3'
  'CNITrack13.mp3'
  'CNITrack14.mp3'
  'CNITrack15.mp3'
  'CNITrack16.mp3'
  'CNITrack16b.mp3'
  'CNITrack17.mp3'
  'CNITrack18.mp3'
  'CNITrack19.mp3'
  'CNITrack20.mp3'
  'CNITrack21.mp3'
  'CNITrack22.mp3'
  'CNITrack23.mp3'
  'CNITrack24.mp3'
)

for id in ${!file_names[*]}
do
  fn=$(printf "CNI-Track%02d.mp3" $id)
  mv "${file_names[$id]}" "$fn"
done

curl 'http://www.midimusicadventures.com/wp-content/uploads/2016/04/CNIFrontCover.jpg' > large_cover.jpg
$magick large_cover.jpg -resize 600x600 cover.jpg

mkdir bkup
cp *.mp3 *.jpg bkup

# now fixup the mp3 tags
track_names=(
 [1]='Main Title Theme'
'On The Beach Of Tahiti'
'ChiChi Bar Theme 1'
'ChiChi Bar Theme 2'
'ChiChi Bar Theme 3'
'ChiChi Bar Theme 4 (Dancing With Stacy)'
'Stacy’s Hut'
'The Morning After'
'Undercover Agent'
'Mission Failed'
'Flight From Tihiti'
'Flight From Tihiti (Arrangement by Quest Studios)'
'Washington D.C.'
'The Pentagon'
'Mission Briefing'
'U.S.S. Blackhawk'
'Russian Submarine Destroyed (Iceman Theme)'
'Swimming In Open Sea'
'Underwater Sabatage'
'Tunisia Compound'
'Freeing The Ambassador'
'Rescued By Stacy'
'The Chase'
'Debriefing'
'Anchor’s Aweigh'
'Closing Themes'
)

odir=Codename-Iceman
mkdir -p $odir
for id in ${!track_names[*]}
do
  fn=$(printf "CNI-Track%02d.mp3" $id)
  id3v2 -D $fn 
  id3v2 -t "${track_names[$id]}"  -A "Codename: Iceman" -y 1989 -a "Sierra" -g 36 -T "$id" $fn
  ffmpeg -i $fn -i cover.jpg -c:a copy -c:v copy -map 0:0 -map 1:0 -id3v2_version 3 \
    -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "$odir/$fn"
done

