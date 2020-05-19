#!/bin/bash
magick=convert # you might have magick
url_base1='http://www.midimusicadventures.com/qs/digital/ssv2cd/Track0[1-9].mp3'
url_base2='http://www.midimusicadventures.com/qs/digital/ssv2cd/Track[10-21].mp3'

curl --remote-name-all "$url_base1"
curl --remote-name-all "$url_base2"

curl 'http://www.midimusicadventures.com/wp-content/uploads/2015/07/SSV2CDCover.jpg' > large_cover.jpg
$magick large_cover.jpg -resize 600x600 cover.jpg
 
# change the single-digit files so they sort properly
for x in Track*.mp3
do
   mv $x "SSV2-$x" 
done
 
mkdir bkup
cp *.mp3 *.jpg bkup

# now fixup the mp3 tags
track_names=(
 [1]="Lost Wages – by Chris Brayman – Leisure Suit Larry 1 Demo"
"Necrotaur Battle – by Aubrey Hodges – Quest For Glory 4"
"Harlem Swinger Speakeasy Theme #2 – by Chris Brayman – Dagger Of Amon Ra"
"Jack’s Birthday Party – by Rob Atesalp – Police Quest 1 VGA"
"Fire Hawk Introduction – by Rob Atesalp – Firehawk"
"Tanya And Toby – by Aubrey Hodges – Quest For Glory 4"
"Whitney – by Mark Seibert – Code-Name: Iceman"
"Eve – by Chris Brayman – Leisure Suit Larry 1 VGA"
"Museum Waltz – by Chris Brayman – Dagger Of Amon Ra"
"Princess Cassima – by Mark Seibert – King’s Quest 5"
"Tulane University – by Ken Allen – Colonel’s Bequest"
"Ship To Gaza – by Mark Seibert – Conquests Of Camelot"
"Robin Hood Introduction – by Mark Seibert & Aubrey Hodges – Conquests Of The Longbow"
"Land Beyond Dreams – by Mark Seibert & Jay Usher – King’s Quest 7"
"Space Quest Medley – by Bob Siebenburg, Ken Allen, Christopher Stephens, Tim Clarke, & Neal Grandstaff – King’s Quest 7"
"Quest For Glory 3 Opening Credits – by Rudy Helm – Quest For Glory 3"
"Heart Of China Introduction – by Dan Latarski & Christopher Stevens – Heart Of China"
"The Tree Hollow – by Dan Kehler – Eco Quest 2"
"Ballade Of Freddy Pharkas – by Aubrey Hodges & Al Lowe – Freddy Pharkas Frontier Pharmacist"
"The Blue Parrot – by Chris Brayman – Quest For Glory 2"
"Space Quest 1 Closing Medley – by Ken Allen – Space Quest 1 VGA"
)

odir="Sierra-STrk-V2"
mkdir -p $odir

for id in ${!track_names[*]}
do
  fn=$(printf "SSV2-Track%02d.mp3" $id)
  id3v2 -D $fn 
  id3v2 -t "${track_names[$id]}"  -A "Sierra Soundtracks Vol 2" -y 1999 -a "Sierra" -g 36 -T "$id" $fn
  ffmpeg -i $fn -i cover.jpg -c:a copy -c:v copy -map 0:0 -map 1:0 -id3v2_version 3 \
    -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "$odir/$fn"
done

