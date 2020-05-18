#!/bin/bash
magick=convert # you might have magick
kq5_base1='http://www.midimusicadventures.com/qs/digital/kq5cd/Track0[1-9].mp3'
kq5_base2='http://www.midimusicadventures.com/qs/digital/kq5cd/Track[10-41].mp3'
kq5_extra='http://www.midimusicadventures.com/wp-content/uploads/2011/09/KQ5_TheDarkForest_SRX_MIX_Draft2.mp3'

curl --remote-name-all "$kq5_base1"
curl --remote-name-all "$kq5_base2"
curl -o Track42.mp3 "$kq5_extra"

curl 'http://www.midimusicadventures.com/wp-content/uploads/2015/07/KQ5CDFrontCover.jpg' > large_cover.jpg
$magick large_cover.jpg -resize 600x600 cover.jpg

mkdir bkup
cp *.mp3 *.jpg bkup

# now fixup the mp3 tags
kq5_names=(
 [1]="Sierra Fanfare"
"Introduction/Opening Themes"
"The Town"
"Village Shops"
"The Weeping Willow"
"The Gnomes (Part One)"
"The Bee Hive"
"King Antony’s March Of The Ants"
"The Desert Oasis"
"Bandit’s Camp (Part One)"
"The Bandits And The Temple"
"Bandit’s Camp (Part Two)"
"Inside The Temple"
"A Gypsy’s Tale"
"The Witch"
"The Dark Forest (Medley)*"
"The Witch’s House"
"The Elf"
"The Weeping Willow (Revisited)"
"The Gnomes (Part Two)"
"The Hog Inn"
"Mountain Pass and Sled Ride"
"A Hungry Eagle"
"The Ice Queen"
"The Yeti"
"Crystal Garden"
"Snatched and Rescued"
"The Boat Ride and The Serpent"
"Harpie Island"
"Poor Cedric"
"The Hermit"
"The Mermaid"
"Mordack’s Castle"
"Mordack’s Dungeon"
"The Dink"
"Mordack’s Pantry"
"Cassima"
"Mordack’s Lab"
"Jailed And Rescued"
"Battle With Mordack"
"Closing Medley"
"The Dark Forest SRX"
)

mkdir Kings-Quest-V
for id in ${!kq5_names[*]}
do
  fn=$(printf "Track%02d.mp3" $id)
  id3v2 -D $fn 
  id3v2 -t "${kq5_names[$id]}"  -A "Kings Quest V" -y 1990 -a "Sierra" -g 36 -T "$id" $fn
  ffmpeg -i $fn -i cover.jpg -c:a copy -c:v copy -map 0:0 -map 1:0 -id3v2_version 3 \
    -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "Kings-Quest-V/$fn"
done

