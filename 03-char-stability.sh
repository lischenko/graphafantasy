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

  # Delegate to world specific image prep script
  PREPARED_IMAGE="/tmp/stab-input.png"
  bash -x \
  worlds/${WORLD}/03-image-prep.sh "${IMAGE_PATH}" "${PREPARED_IMAGE}"
  
  # Too long of a prompt causes HTTP 400
  export IMAGE_DESC
  PROMPT=$(envsubst < worlds/${WORLD}/prompt-03-char-stability.txt | head -c 1950)
  echo $PROMPT
 
  URL="https://api.stability.ai/v1/generation/stable-diffusion-xl-1024-v1-0/image-to-image"
#  URL="https://api.stability.ai/v1/generation/stable-diffusion-v1-6/image-to-image"
  OUT_FILE=${STAB_IMG_PATH}/${CHAR_ID}-${T}.jpg
  echo $OUT_FILE

  bash -x \
  worlds/${WORLD}/03-stabai-call.sh ${STABAI_KEY} ${URL} "${PREPARED_IMAGE}" "${PROMPT}" "${OUT_FILE}"
done
