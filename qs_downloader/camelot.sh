#!/bin/bash
magick=convert # you might have magick

url_base1='http://www.midimusicadventures.com/qs/digital/camelot/Track0[1-9].mp3'
url_base2='http://www.midimusicadventures.com/qs/digital/camelot/Track[10-27].mp3'
extra_url=(
  [28]='http://www.midimusicadventures.com/qs/digital/camelot/catacombs.mp3'
  'http://www.midimusicadventures.com/qs/digital/camelot/SpamALot.mp3'
  'http://www.midimusicadventures.com/qs/digital/camelot/TheOldOnes.mp3'
  'http://www.midimusicadventures.com/qs/digital/camelot/DublinRome.mp3'
  'http://www.midimusicadventures.com/qs/digital/camelot/Pool.mp3'
  'http://www.midimusicadventures.com/qs/digital/camelot/Cobra.mp3'
  'http://www.midimusicadventures.com/qs/digital/camelot/Death.mp3'
  'http://www.midimusicadventures.com/qs/digital/camelot/FatimaSpell.mp3'
)

curl --remote-name-all "$url_base1"
curl --remote-name-all "$url_base2"

for id in ${!extra_url[*]}
do
  fn=$(printf "Track%02d.mp3" $id)
  curl -o "$fn" "${extra_url[$id]}"
done

curl 'http://www.midimusicadventures.com/wp-content/uploads/2015/10/CamelotFrontCover.jpg' > large_cover.jpg
$magick large_cover.jpg -resize 600x600 cover.jpg

# change the single-digit files so they sort properly
for x in Track*.mp3
do
   mv $x "CCam-$x" 
done
 
mkdir bkup
cp *.mp3 *.jpg bkup

# now fixup the mp3 tags
track_names=(
 [1]='Main Title Theme'
'Introduction'
'Arthur’s Room'
'Merlin'
'Chapel Of The Two Gods'
'Gwenhyver'
'Camelot Castle'
'The Widdershins'
'The Wild Boars'
'The Black Knight'
'The Stone Circle (The Witch And Lady Elayne)'
'Ruins Of Glastonbury Tor'
'The Mad Monk'
'The Ice Maiden'
'Ship To Gaza'
'Gaza'
'Al-Sirat'
'Jerusalem'
'Fatima'
'The Catacombs'
'Aphrodite'
'Temple Of Aphrodite'
'The Saracen Battle'
'The Dove'
'The Grail'
'The Thief'
'Closing Scenes'
'CAMELOT CATACOMBS METALIZED – by Brandon Blume'
'Ham And Jam And Spam A Lot'
'The Old Ones'
'Ship To Dublin and Rome'
'Pool Of Siloam'
'Valley Of The Cobras'
'Death By Cobra'
'The Spell Of Fatima'
)

odir="Conquest-Camelot"
mkdir -p $odir

for id in ${!track_names[*]}
do
  fn=$(printf "CCam-Track%02d.mp3" $id)
  id3v2 -D $fn 
  id3v2 -t "${track_names[$id]}"  -A "Conquests of Camelot" -y 1990 -a "Sierra" -g 36 -T "$id" $fn
  ffmpeg -i $fn -i cover.jpg -c:a copy -c:v copy -map 0:0 -map 1:0 -id3v2_version 3 \
    -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "$odir/$fn"
done

