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

  PROMPT=$(m4 -DCHAR_ID="$CHAR_ID" -DCHAR_NAME="$CHAR_NAME" -DCHAR_TEMPLATE="${CHAR_TEMPLATE}"  -DCHAR_ORIG_DESC="$CHAR_ORIG_DESC" -DCHAR_DESC="$CHAR_DESC" worlds/${WORLD}/prompt-02-describe-ref-images.txt)
  echo $PROMPT

  req=$(echo $PROMPT | WORLD=${WORLD} CHAR_ID=${CHAR_ID} S3_BUCKET=${S3_BUCKET} jq -R '{
    "model": "gpt-4-vision-preview",
    "messages": [
      {
        "role": "user",
        "content": [
  	  {"type": "text", "text": .},
          {"type": "image_url", "image_url": {"url": "https://\(env.S3_BUCKET).s3.us-west-1.amazonaws.com/\(env.WORLD)/\(env.CHAR_ID).jpg"}}
        ]
      }
    ],
    "max_tokens": 500
  }')
  echo $req

 resp=$(curl https://api.openai.com/v1/chat/completions \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer ${OPENAI_KEY}" \
		-d "$req")

 echo $resp | tr -d '\n' | jq -r '.choices[0].message.content' | tee ${DESC_IMG_PATH}/${CHAR_ID}-${T}.txt
done
