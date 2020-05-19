#!/bin/bash

base='http://www.midimusicadventures.com'
url_list=(
[1]="$base/qs/digital/castle/01SierraFanfare.mp3" 
"$base/qs/digital/castle/02IntroAndMainTheme.mp3"
"$base/qs/digital/castle/03MathRoom.mp3"
"$base/qs/digital/castle/04ClockRoom.mp3"
"$base/qs/digital/castle/05ComputerHall.mp3"
"$base/qs/digital/castle/06InTheComputer.mp3"
"$base/qs/digital/castle/07RobotMaze.mp3"
"$base/qs/digital/castle/08Robots.mp3"
"$base/qs/digital/castle/09LanguageHall.mp3"
"$base/qs/digital/castle/10PuzzleRoom.mp3"
"$base/qs/digital/castle/11CodeRoom.mp3"
"$base/qs/digital/castle/12Planetarium.mp3"
"$base/qs/digital/castle/13Aliens.mp3"
"$base/qs/digital/castle/14MonolithI.mp3"
"$base/qs/digital/castle/15MonolithII.mp3"
"$base/qs/digital/castle/16DrBrainsOffice.mp3" 
)

for id in ${!url_list[*]}
do
  fn=$(printf "DRBrain-Track%02d.mp3" $id)
  curl -o "$fn" "${url_list[$id]}"
done

curl 'http://www.midimusicadventures.com/wp-content/uploads/2015/09/castleBrain.jpg' > cover.jpg

mkdir bkup
cp *.mp3 *.jpg bkup

# now fixup the mp3 tags
track_names=(
[1]="Sierra Fanfare" 
"Introduction/Main Title Theme"
"Math Room"
"Clock Room"
"Computer Hall"
"Inside The Computer"
"Robot Maze"
"Robots"
"Language Hall"
"Puzzle Room"
"Code Room"
"Planetarium"
"Aliens"
"Monolith"
"Monolith II"
"Dr. Brain's Office" 
)

odir=Castle-Dr-Brain
mkdir -p $odir
for id in ${!track_names[*]}
do
  fn=$(printf "DRBrain-Track%02d.mp3" $id)
  id3v2 -D $fn 
  id3v2 -t "${track_names[$id]}"  -A "Castle of Dr. Brain" -y 1991 -a "Sierra" -g 36 -T "$id" $fn
  ffmpeg -i $fn -i cover.jpg -c:a copy -c:v copy -map 0:0 -map 1:0 -id3v2_version 3 \
    -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "$odir/$fn"
done

