#!/bin/bash
set -o nounset
set -o errexit

SRC_IMAGE="$1"
DST_IMAGE="$2"

# Resize, replace blanks with noise 
convert -size 832x1216 xc: +noise Random /tmp/noise_background.jpg
convert ${SRC_IMAGE} -resize 832x1216 /tmp/input_resized.jpg
convert /tmp/noise_background.jpg /tmp/input_resized.jpg -gravity center -composite "${DST_IMAGE}"
