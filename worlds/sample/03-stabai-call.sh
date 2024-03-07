#!/bin/bash
set -o nounset
set -o errexit

STABAI_KEY="$1"
URL="$2"
IMAGE_PATH="$3"
PROMPT="$4"
OUT_FILE="$5"

curl -f -sS -X POST "${URL}" \
     -H 'Content-Type: multipart/form-data' \
     -H 'Accept: image/png' \
     -H "Authorization: Bearer ${STABAI_KEY}" \
     -F "init_image=@${IMAGE_PATH}" \
     -F 'init_image_mode=IMAGE_STRENGTH' \
     -F 'image_strength=0.38' \
     -F "text_prompts[0][text]=${PROMPT}" \
     -F "text_prompts[0][weight]=1" \
     -F "text_prompts[1][text]=blurry, bad, low detail, out of focus" \
     -F "text_prompts[1][weight]=-1" \
     -F 'cfg_scale=7' \
     -F 'samples=1' \
     -F 'steps=45' \
     -F "style_preset=comic-book" \
     -o "${OUT_FILE}"
