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

  CARD_ACTION=""

  TEMPLATES_PATH="worlds/${WORLD}/templates"
  TEMPLATE_FILE="${TEMPLATES_PATH}/${CHAR_TEMPLATE}.svg"

  IMAGE_STAB_FILE=$(find ${STAB_IMG_PATH} -type f -name ${CHAR_ID}'-[0-9]*\.jpg'|sort|tail -1)

  IMAGE_BASE="${CARDS_PATH}/${CHAR_ID}"

  CHAR_RASTER=$(realpath ${IMAGE_STAB_FILE})
  echo CHAR_ID=$CHAR_ID CHAR_NAME=$CHAR_NAME CHAR_DESC=$CHAR_DESC TEMPLATE_FILE=${TEMPLATE_FILE} CHAR_RASTER="${CHAR_RASTER}"
  m4 -DCHAR_RASTER="${CHAR_RASTER}" -DCHAR_ID="$CHAR_ID" -DCHAR_NAME="$CHAR_NAME" -DCHAR_DESC="$CHAR_DESC" -DCARD_ACTION="$CARD_ACTION" $TEMPLATE_FILE > "${IMAGE_BASE}.svg"
    
  #convert  "${IMAGE_BASE}.svg" "${IMAGE_BASE}.png"
  inkscape  "${IMAGE_BASE}.svg"  --export-type=png --export-filename="${IMAGE_BASE}.png"
done
