#!/bin/bash
magick=convert # you might have magick
url_base1='http://www.midimusicadventures.com/qs/digital/lb2cd/Track0[1-9].mp3'
url_base2='http://www.midimusicadventures.com/qs/digital/lb2cd/Track[10-35].mp3'
extra_url=(
  [36]="http://www.midimusicadventures.com/qs/digital/lb2cd/AmonRa.mp3"
"http://www.midimusicadventures.com/qs/digital/lb2cd/AmonRaCult.mp3"
"http://www.midimusicadventures.com/qs/digital/lb2cd/TaxiToMuseum.mp3"
"http://www.midimusicadventures.com/qs/digital/lb2cd/BatAttack.mp3"
"http://www.midimusicadventures.com/qs/digital/lb2cd/ZiggyDead.mp3"
"http://www.midimusicadventures.com/qs/digital/lb2cd/CarringtonDead.mp3"
"http://www.midimusicadventures.com/qs/digital/lb2cd/LeachDead.mp3"
"http://www.midimusicadventures.com/qs/digital/lb2cd/CountessDead.mp3"
"http://www.midimusicadventures.com/qs/digital/lb2cd/LauraDies.mp3"
)

curl --remote-name-all "$url_base1"
curl --remote-name-all "$url_base2"

for id in ${!extra_url[*]}
do
  fn=$(printf "Track%02d.mp3" $id)
  curl -o "$fn" "${extra_url[$id]}"
done

curl 'http://www.midimusicadventures.com/wp-content/uploads/2015/07/LB2FrontCover.jpg' > large_cover.jpg
$magick large_cover.jpg -resize 600x600 cover.jpg

# change the single-digit files so they sort properly
for x in Track*.mp3
do
   mv $x "LB2-$x" 
done
 
mkdir bkup
cp *.mp3 *.jpg bkup

# now fixup the mp3 tags
track_names=(
 [1]="Opening Scenes - INTRODUCTION"
"Sam Augustini - INTRODUCTION"
"Acts Theme - ACT I: A NOSE FOR NEWS"
"Luigi – The Vender - ACT I: A NOSE FOR NEWS"
"Police Station – Detective O’Riley - ACT I: A NOSE FOR NEWS"
"The Taxi Ride - ACT I: A NOSE FOR NEWS"
"Lo Fats Chinese Laundry - ACT I: A NOSE FOR NEWS"
"Harlem Swinger Speakeasy Theme #1 - ACT I: A NOSE FOR NEWS"
"Harlem Swinger Speakeasy Theme #2 (Archaeologist Song: MIDI version) - ACT I: A NOSE FOR NEWS"
"Harlem Swinger Speakeasy Theme #2 (Archaeologist Song: In-game digital version) - ACT I: A NOSE FOR NEWS"
"Harlem Swinger Speakeasy Theme #3 - ACT I: A NOSE FOR NEWS"
"The Leyendecker Museum (Security Chief Wolf Heimlich) - ACT II: SUSPECTS ON PARADE"
"The Museum Waltz - ACT II: SUSPECTS ON PARADE"
"Steve Dorian - ACT II: SUSPECTS ON PARADE"
"Ancient Egypt Exhibit - ACT II: SUSPECTS ON PARADE"
"Dr. Pippin Carter’s Body - ACT III: ON THE CUTTING EDGE"
"Questioning The Witnesses - ACT III: ON THE CUTTING EDGE"
"Introduction To Ernie Leach - ACT III: ON THE CUTTING EDGE"
"Museum Investigation (Part One) - ACT III: ON THE CUTTING EDGE"
"Yevette Delacroix - ACT III: ON THE CUTTING EDGE"
"Watney Little - ACT III: ON THE CUTTING EDGE"
"Hiding Behind the Tapestry (Secret Passage) - ACT III: ON THE CUTTING EDGE"
"Wolf Heimlich - ACT III: ON THE CUTTING EDGE"
"The Dagger Of Amon Ra - ACT III: ON THE CUTTING EDGE"
"Ernie Leach - ACT III: ON THE CUTTING EDGE"
"Yevette’s Men - ACT III: ON THE CUTTING EDGE"
"Museum Investigation (Part Two) - ACT IV: MUSEUM OF THE DEAD"
"Mr. Myklos - ACT IV: MUSEUM OF THE DEAD"
"Barney The Snake - ACT IV: MUSEUM OF THE DEAD"
"Running From Mr. X - ACT V: REX TAKES A BITE OUT OF CRIME"
"Hiding From Mr. X - ACT V: REX TAKES A BITE OUT OF CRIME"
"The Cult Of Amon Ra (Rameses Najeer) - ACT V: REX TAKES A BITE OUT OF CRIME"
"Mr. X Revealed - ACT V: REX TAKES A BITE OUT OF CRIME"
"Henri LeMort (The Coroner) - ACT VI: THE CORONERS INQUEST"
"Laura And Steve (Love Song) - ACT VI: THE CORONERS INQUEST"
"Amon Ra Chant"
"Amon Ra Cult"
"Taxi To The Museum"
"Bat Attack"
"Lawrence Zigfeld Dead"
"Dr. Carrington Dead"
"Ernie Leach Dead"
"The Countess Dead"
"Laura Dies"
)

odir="Dagger-of-Amon-Ra"
mkdir -p $odir

for id in ${!track_names[*]}
do
  fn=$(printf "LB2-Track%02d.mp3" $id)
  id3v2 -D $fn 
  id3v2 -t "${track_names[$id]}"  -A "Dagger of Amon Ra" -y 1992 -a "Sierra" -g 36 -T "$id" $fn
  ffmpeg -i $fn -i cover.jpg -c:a copy -c:v copy -map 0:0 -map 1:0 -id3v2_version 3 \
    -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "$odir/$fn"
done

