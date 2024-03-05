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

  TEMPLATES_PATH="worlds/${WORLD}/templates"
  TEMPLATE_FILE="${TEMPLATES_PATH}/${CHAR_TEMPLATE}.svg"

  IMAGE_STAB_FILE=$(find ${STAB_IMG_PATH} -type f -name ${CHAR_ID}'*'|sort|tail -1)
  CHAR_RASTER=$(realpath ${IMAGE_STAB_FILE})

  echo CHAR_ID=$CHAR_ID CHAR_NAME=$CHAR_NAME CHAR_DESC=$CHAR_DESC TEMPLATE_FILE=${TEMPLATE_FILE} CHAR_RASTER="${CHAR_RASTER}"

  CHAR_NAME=""  # NB: hack to hide the name
  CARD_ACTION=""
  
  m4 -DCHAR_RASTER="${CHAR_RASTER}" -DCHAR_ID="$CHAR_ID" -DCHAR_NAME="$CHAR_NAME" -DCHAR_DESC="$CHAR_DESC" -DCARD_ACTION="$CARD_ACTION" $TEMPLATE_FILE > ${TG_STICKERS_PATH}/${CHAR_ID}.svg
    
  inkscape ${TG_STICKERS_PATH}/${CHAR_ID}.svg --export-type=png --export-filename=${TG_STICKERS_PATH}/${CHAR_ID}.png --export-width=329 --export-height=512
done
