#!/bin/bash
magick=convert # you might have magick

kq6_base='http://www.midimusicadventures.com/qs/digital/kq6cd/xr/kq6([1-53]).mp3'
curl --remote-name-all "$kq6_base"
curl 'http://www.midimusicadventures.com/wp-content/uploads/2015/07/KQ6_CDFrontCover.jpg' > large_cover.jpg
$magick large_cover.jpg -resize 600x600 cover.jpg

# change the single-digit files so they sort properly
for x in kq6*.mp3
do
   nx=$(echo $x | sed -e 's/(\([0-9]\))/(0\1)/' -e 's/(\(..\))/-\1/')
   mv $x $nx 
done
 
# now fixup the mp3 tags
kq6_names=(
 [1]="Opening Movie & Introduction"
"The Village (The Beach)"
"The Castle"
"Lord Abdul Alhazred"
"Beauty, The Young Serving Girl"
"The Boy In The Water"
"The Ferryman"
"Jollo"
"Shamir (The Man In Black)"
"Song Of The Nightingale"
"The Oyster"
"Sensing Gnomes"
"The Bookworm"
"Black Widow’s Web"
"Dangling Participle"
"The Garden"
"Chessboard Land"
"The Gardener"
"Message To Cassima (Girl In The Tower)"
"The Wall Flowers"
"The Old Woman"
"The Cave"
"City Of The Winged Ones"
"The Catacombs"
"A Trap!"
"Minitaur Battle"
"Lady Celeste"
"The Oracle"
"Isle Of The Mists"
"Beauty And The Beast"
"Alexander’s Suicide"
"The Druids (& The Rain Spell)"
"Arch Druid"
"Nightmare"
"Journey To The Realm Of The Dead"
"The Realm Of The Dead"
"Underworld Entrance"
"Dance Of The Bones (Dem Bones)"
"River Styx"
"Death Waits For No Man"
"Lord Of The Dead"
"Castle Dungeon"
"Dungeon Cell"
"Secret Passage"
"Princess Cassima"
"Wedding Music"
"The Guards"
"Treasure Room"
"Stopping The Wedding"
"Lord Abdul Alhazred Defeated"
"Alexander And Cassima’s Wedding"
"Closing Scenes"
"Girl In The Tower – MIDI Version"
)

mkdir Kings-Quest-VI
for id in ${!kq6_names[*]}
do
  fn=$(printf "kq6-%02d.mp3" $id)
  id3v2 -D $fn 
  id3v2 -t "${kq6_names[$id]}"  -A "Kings Quest VI" -y 1992 -a "Sierra" -g 36 -T "$id" $fn
  ffmpeg -i $fn -i cover.jpg -c:a copy -c:v copy -map 0:0 -map 1:0 -id3v2_version 3 \
    -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" Kings-Quest-VI/$fn
done
