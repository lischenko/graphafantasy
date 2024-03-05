#!/bin/bash
set -o nounset
set -o errexit

source common.sh 

cat $(find_last_db) | while IFS=$'\t' read -r CHAR_ID CHAR_NAME CHAR_TEMPLATE CHAR_ORIG_DESC CHAR_DESC
do
  # Skip records if a specific ID is targeted and it doesn't match the current record
  if [ ! -z "${TARGET_CHAR_ID}" ] && [ ! "${CHAR_ID}" = "${TARGET_CHAR_ID}" ]; then
    continue
  fi

  IMAGE_DESC_FILE=$(find ${DESC_IMG_PATH} -type f -name ${CHAR_ID}'*'txt|sort|tail -1)
  IMAGE_DESC=$(cat "${IMAGE_DESC_FILE}")

  IMAGE_PATH="${REF_IMG_PATH}/${CHAR_ID}.jpg"

  # Make grayscale, resize, replace blanks with noise 
  RESIZED_IMAGE="/tmp/stab-input.jpg"
  convert -size 832x1216 xc: +noise Random /tmp/noise_background.jpg
  convert ${IMAGE_PATH} -resize 832x1216 /tmp/input_resized.jpg

  # Delegate to world specific image prep if available
  if [ -f worlds/${WORLD}/03-image-prep.sh ]; then
      echo "custom prep script"
      worlds/${WORLD}/03-image-prep.sh "${RESIZED_IMAGE}"
  else
      convert /tmp/noise_background.jpg /tmp/input_resized.jpg -gravity center -composite "${RESIZED_IMAGE}"
  fi
  
  IMAGE_PATH=${RESIZED_IMAGE}

  # Too long of a prompt causes HTTP 400
  export IMAGE_DESC
  PROMPT=$(envsubst < worlds/${WORLD}/prompt-03-char-stability.txt | head -c 1950)
  echo $PROMPT
 
  URL="https://api.stability.ai/v1/generation/stable-diffusion-xl-1024-v1-0/image-to-image"
#  URL="https://api.stability.ai/v1/generation/stable-diffusion-v1-6/image-to-image"
  OUT_FILE=${STAB_IMG_PATH}/${CHAR_ID}-${T}.jpg
  echo $OUT_FILE

  if [ -f worlds/${WORLD}/03-stabai-call.sh ]; then
      echo "Custom stability ai call"
      bash -x worlds/${WORLD}/03-stabai-call.sh ${STABAI_KEY} ${URL} ${IMAGE_PATH} "${PROMPT}" "${OUT_FILE}"
  else
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
  fi


done
