#!/bin/bash

for x in *.flac
do
  ffmpeg -i $x -i cover.jpg -map 1 -map 0 -c:a alac -c:v copy -disposition:0 attached_pic "${x%flac}m4a"
done

