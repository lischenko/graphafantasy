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

  IMAGE_FILE=$(find ${STAB_IMG_PATH} -type f -name ${CHAR_ID}'-[0-9]*\.jpg'|sort|tail -1)
  RESIZED_IMAGE="/tmp/stab-vid-input.jpg"
  # cut excess
  convert ${IMAGE_FILE} -resize 576x1024^ -gravity center -extent 576x1024 ${RESIZED_IMAGE}

  IMAGE_FILE=${RESIZED_IMAGE}

  OUT_JSON=${VIDEO_PATH}/${CHAR_ID}-${T}.json
  echo $OUT_JSON

  URL="https://api.stability.ai/v2alpha/generation/image-to-video"

  curl -f -sS -X POST "$URL" \
       -H 'Content-Type: multipart/form-data' \
       -H 'Accept: image/png' \
       -H "Authorization: Bearer ${STABAI_KEY}" \
       -F image=@"${IMAGE_FILE}" \
       -F cfg_scale=2.0 \
       -F motion_bucket_id=48 \
       -o "$OUT_JSON"
done
