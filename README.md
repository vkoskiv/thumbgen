## Super simple thumbnail generator for my YouTube videos.

Requires imagemagick and ffmpeg to be installed. You probably also need the Helvetica-Bold font. Just tweak the script if it doesn't work!

Usage: `./thumbgen.sh "<video file>" <your title string>`
At least for now, provide the path to your video file in quotes, so it doesn't mess up the arguments parsing.
Better yet, submit a PR that fixes this obvious oversight!

# Example:

Run `./thumbgen.sh "your_cool_vid.mkv" Integrating a flux capacitor into our time machine!`

And you should get an image like this:

<p align="center">
	<img src="https://raw.githubusercontent.com/vkoskiv/thumbgen/master/example.png" width="768">
</p>

Not perfect, but hey, beats trying to make it in GIMP!

## Caveats

* ~~It currently assumes any given video file is precisely 1920x1080~~ *FIXED*
* It likely has bugs
* The text will overflow if you type in any more than the example above^
