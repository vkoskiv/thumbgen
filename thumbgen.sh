#!/bin/bash

# check args
if [ $# -lt 2 ]; then
	echo "Provide the video file and text, bro"
	exit -1
fi

thumbstr=$(echo "$*" | cut -d ' ' -f2-)
echo "$thumbstr"

# Grab a random frame from the video
TOTAL_FRAMES=$(ffmpeg -i $1 -vcodec copy -acodec copy -f null /dev/null 2>&1 | grep frame | cut -d ' ' -f 2 | sed s/frame=//)
FPS=$(ffprobe -v error -select_streams v -of default=noprint_wrappers=1:nokey=1 -show_entries stream=avg_frame_rate $1 | cut -d'/' -f 1)
RANDOM_FRAME=$[RANDOM % TOTAL_FRAMES]
TIME=$((RANDOM_FRAME/FPS))
ffmpeg -ss $TIME -i $1 -frames:v 1 $RANDOM_FRAME.png 2>&1 > /dev/null
FILENAME="$RANDOM_FRAME.png"

# Superimpose stuff with imagemagick
# Add the dark rectangle
convert $FILENAME -strokewidth 0 -fill "rgba(0, 0, 0, 0.85)" -draw "rectangle 0,0 960,1080" temp.png

convert temp.png \( -gravity Center -pointsize 180 -size 900x -background transparent -fill white -font helvetica-bold caption:"$thumbstr" \) -gravity West -geometry +25+0 -composite thumbnail.png
rm temp.png
rm $RANDOM_FRAME.png
