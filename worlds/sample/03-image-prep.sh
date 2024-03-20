#!/bin/bash
set -o nounset
set -o errexit

SRC_IMAGE="$1"
DST_IMAGE="$2"

# Resize the source image, auto-orient it, and then crop it to the desired size
convert ${SRC_IMAGE} -auto-orient -resize 832x1216^ -gravity center -extent 832x1216 "${DST_IMAGE}"
