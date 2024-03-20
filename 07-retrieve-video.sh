#!/bin/bash
set -o nounset
set -o errexit

source common.sh 

URL="https://api.stability.ai/v2alpha/generation/image-to-video"

cat $(find_last_db) | while IFS=$'\t' read -r CHAR_ID CHAR_NAME CHAR_TEMPLATE CHAR_ORIG_DESC CHAR_DESC
do
    # Skip records if a specific ID is targeted and it doesn't match the current record
    if [ ! -z "${TARGET_CHAR_ID}" ] && [ ! "${CHAR_ID}" = "${TARGET_CHAR_ID}" ]; then
	continue
    fi

    JSON_FILE=$(find ${VIDEO_PATH}/ -type f -name ${CHAR_ID}'-[0-9]*\.json'|sort|tail -1)

    GENERATION_ID=$(jq -r '.id' ${JSON_FILE})

    URL2="${URL}/result/$GENERATION_ID"

    OUT_MP4=${JSON_FILE%.*}.mp4

    while [ ! -f "${OUT_MP4}" ]; do
	HTTP_STATUS=$(curl -f -sS "$URL2" \
			   -w '%{http_code}' \
			   -H "Authorization: Bearer ${STABAI_KEY}" \
			   -H 'Accept: video/*' \
			   -o "${OUT_MP4}"
		   )

	case $HTTP_STATUS in
	    202)
		echo "Still processing. Retrying in 10 seconds..."
		rm ${OUT_MP4}
		sleep 10
		;;
	    200)
		echo "Download complete!"
		break
		;;
	    4*|5*)
		mv "./output.mp4" "./error.json"
		echo "Error: Check ./error.json for details."
		mv ${OUT_MP4} ${OUT_MP4}.error
		exit 1
		;;
	esac
    done
    
done
