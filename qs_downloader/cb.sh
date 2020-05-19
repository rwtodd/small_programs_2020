#!/bin/bash
magick=convert # you might have magick

url_base1='http://www.midimusicadventures.com/qs/digital/cbcd/Track0[1-9].mp3'
url_base2='http://www.midimusicadventures.com/qs/digital/cbcd/Track[10-13].mp3'
url_base3='http://www.midimusicadventures.com/qs/digital/cbcd/Track14a.mp3'
url_base4='http://www.midimusicadventures.com/qs/digital/cbcd/Track[15-31].mp3'

curl --remote-name-all "$url_base1"
curl --remote-name-all "$url_base2"
curl -o Track14.mp3 "$url_base3" 
curl --remote-name-all "$url_base4"

curl 'http://www.midimusicadventures.com/wp-content/uploads/2015/07/CBFrontCover.jpg' > large_cover.jpg
$magick large_cover.jpg -resize 600x600 cover.jpg

# change the single-digit files so they sort properly
for x in Track*.mp3
do
   mv $x "CB-$x" 
done
 
mkdir bkup
cp *.mp3 *.jpg bkup

# now fixup the mp3 tags
track_names=(
 [1]='Copy Protection'
'Title Theme'
'Introduction'
'Tulane University'
'The Island'
'Jeeves'
'Dinner With The Colonel'
'Act I: Fifi And The Colonel'
'Death By Shower and Spying'
'The Chapel'
'Billiard Room Victrola (Theme #1)'
'Billiard Room Victrola (Theme #2)'
'Billiard Room Victrola (Theme #3)'
'Billiard Room Victrola (Theme #4)'
'Billiard Room Player Piano (Theme #1)'
'Billiard Room Player Piano (Theme #2)'
'Billiard Room Player Piano (Theme #3)'
'Billiard Room Player Piano (Theme #4)'
'Billiard Room Player Piano (Theme #5)'
'Drunk Ethel'
'Fifi’s Victrola (Theme 1)'
'Fifi’s Victrola (Theme 2) .'
'Celie'
'Rudy And Clarence Fight'
'Fifi’s Victrola (Theme 3 – Fifi’s Bolero)'
'The Bodies In The Basement'
'The Colonel Confronts Rudy'
'Mighty Fine Shootin’ For A Gal'
'The End #1 (Laura Leaves The Mansion)'
'The End #2 (The Colonel Shot)'
'The Long Ride Home'
)

odir="Colonels-Bequest"
mkdir -p $odir

for id in ${!track_names[*]}
do
  fn=$(printf "CB-Track%02d.mp3" $id)
  id3v2 -D $fn 
  id3v2 -t "${track_names[$id]}"  -A "Colonel's Bequest" -y 1989 -a "Sierra" -g 36 -T "$id" $fn
  ffmpeg -i $fn -i cover.jpg -c:a copy -c:v copy -map 0:0 -map 1:0 -id3v2_version 3 \
    -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "$odir/$fn"
done

