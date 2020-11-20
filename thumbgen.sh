#!/bin/bash

# check args
if [ $# -lt 2 ]; then
	echo "Provide the video file and text, bro"
	exit 255
fi

thumbstr=$(echo "$*" | cut -d ' ' -f2-)
echo "Working..."

# Grab a random frame from the video
TOTAL_FRAMES=$(ffmpeg -i "$1" -vcodec copy -acodec copy -f null /dev/null 2>&1 | grep frame | cut -d ' ' -f 2)
FPS=$(ffprobe -v error -select_streams v -of default=noprint_wrappers=1:nokey=1 -show_entries stream=avg_frame_rate "$1" | cut -d'/' -f 1)
RANDOM_FRAME=$((RANDOM % TOTAL_FRAMES))
TIME=$((RANDOM_FRAME/FPS))
ffmpeg -ss $TIME -i "$1" -frames:v 1 "$RANDOM_FRAME".png > /dev/null 2>&1
FILENAME="$RANDOM_FRAME.png"

VIDEO_WIDTH=$(ffprobe -v error -select_streams v -of default=noprint_wrappers=1 -show_entries stream "$1" | grep "^width=" | cut -d'=' -f2)
VIDEO_HEIGHT=$(ffprobe -v error -select_streams v -of default=noprint_wrappers=1 -show_entries stream "$1" | grep "^height=" | cut -d'=' -f2)

# Superimpose stuff with imagemagick
# Add the dark rectangle
convert $FILENAME -strokewidth 0 -fill "rgba(0, 0, 0, 0.85)" -draw "rectangle 0,0 $(($VIDEO_WIDTH / 2)),$VIDEO_HEIGHT" temp.png

# (What I use) FONT="/Users/vkoskiv/Library/Fonts/SFMono-Regular.otf"
FONT="helvetica-bold"
LINE_SPACING=25
FONTSIZE=180
TEXTBOX_WIDTH=$(((VIDEO_WIDTH / 2) - 60))
echo "$TEXTBOX_WIDTH"
# And finally, add the title text.
convert temp.png \( -gravity Center -pointsize $FONTSIZE -size "$TEXTBOX_WIDTH"x -background transparent -fill white -font $FONT -interline-spacing $LINE_SPACING caption:"$thumbstr" \) -gravity West -geometry +25+0 -composite thumbnail.png
rm temp.png
rm "$RANDOM_FRAME".png
echo "Wrote thumbnail.png"
