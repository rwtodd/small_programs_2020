#!/bin/bash
magick=convert # you might have magick
base='http://www.midimusicadventures.com/qs/digital/ssv3cd/'
url_base1="$base/Track0[1-9].mp3"
url_base2="$base/Track[10-19].mp3"

curl --remote-name-all "$url_base1"
curl --remote-name-all "$url_base2"

curl 'http://www.midimusicadventures.com/wp-content/uploads/2015/07/SSV3Cover.jpg' > large_cover.jpg
$magick large_cover.jpg -resize 600x600 cover.jpg
 
# change the single-digit files so they sort properly
for x in Track*.mp3
do
   mv $x "SSV3-$x" 
done
 
mkdir bkup
cp *.mp3 *.jpg bkup

# now fixup the mp3 tags
track_names=(
 [1]="The Larry Theme (Where’s Dildo) – by Al Lowe & Mark Seibert – Leisure Suit Larry Love For Sail"
"The Colonel – by Ken Allen – The Colonel’s Bequest"
"Camelot Closing Theme – by Mark Seibert – Conquests Of Camelot"
"Ballade Of Freddy Pharkas – by Al Lowe & Aubrey Hodges – Freddy Pharkas Frontier Pharmacist"
"Half-Life Closing Credits – by Kelly Bailey – Half-Life"
"St. George Book Shop – by Robert Holmes – Gabriel Knight Sins Of The Fathers"
"The Disco – by Chris Brayman – Leisure Suit Larry 1"
"Silpheed Closing Theme – by Game Arts of Japan – Silpheed"
"Spider – by Don Latarski & Christopher Stevens – Willy Beamish"
"Stacy’s Song – by Mark Seibert – Code-name: Iceman"
"King’s Quest 6 Medley – by Chris Brayman – King’s Quest 6"
"King’s Quest 1 Closing Themes – by Ken Allen – King’s Quest 1"
"Space Quest 3 Medley – by Bob Siebenberg – Space Quest 3"
"Cetus/Toxic Waste Dump – by Chris Brayman – Eco Quest 1"
"Hero’s Quest 1 Closing Theme – by Mark Seibert – Hero’s Quest 1"
"8-Rear – by Christopher Stevens & Tim Clarke – Space Quest 6"
"Iceman! – by Mark Seibert – Code-name: Iceman"
"The Death Of Dr. Carrington – by Chris Brayman – Dagger Of Amon Ra"
"Old Nugget Saloon & The Accident – by Jan Hammer – Police Quest 3"
)

odir="Sierra-STrk-V3"
mkdir -p $odir

for id in ${!track_names[*]}
do
  fn=$(printf "SSV3-Track%02d.mp3" $id)
  id3v2 -D $fn 
  id3v2 -t "${track_names[$id]}"  -A "Sierra Soundtracks Vol 3" -y 1999 -a "Sierra" -g 36 -T "$id" $fn
  ffmpeg -i $fn -i cover.jpg -c:a copy -c:v copy -map 0:0 -map 1:0 -id3v2_version 3 \
    -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "$odir/$fn"
done

