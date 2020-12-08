#!/usr/bin/env bash

# check args
if (( $# >= 2 )); then
    file=$1
    if ! file --mime-type -b "$file" | grep -qE '^video/'
    then
	echo "Error: $1 is not a video." >&2
	echo 'Usage: '$0' "<path to video file>" <Your title string>'
	exit 1
    fi
else
    echo "Usage: $0 \"<path to video file>\" <Your title string>"
    exit 255
fi

shift # Skip the first argument, i.e. the video file.
thumbstr="$*"
echo "Working..."

# Grab a random frame from the video
TOTAL_FRAMES=$(ffmpeg -i "$file" -vcodec copy -acodec copy -f null /dev/null 2>&1 | awk '/frame/ {print $2}')
FPS=$(ffprobe -v error -select_streams v -of default=noprint_wrappers=1:nokey=1 -show_entries stream=avg_frame_rate "$file" | cut -d'/' -f 1)
RANDOM_FRAME=$((RANDOM % TOTAL_FRAMES))
TIME=$((RANDOM_FRAME/FPS))
ffmpeg -ss $TIME -i "$file" -frames:v 1 "$RANDOM_FRAME".png > /dev/null 2>&1
FILENAME="$RANDOM_FRAME.png"

VIDEO_WIDTH=$(ffprobe -v error -select_streams v -of default=noprint_wrappers=1 -show_entries stream "$file" | grep "^width=" | cut -d'=' -f2)
VIDEO_HEIGHT=$(ffprobe -v error -select_streams v -of default=noprint_wrappers=1 -show_entries stream "$file" | grep "^height=" | cut -d'=' -f2)

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
echo thumbnail: $thumbstr
