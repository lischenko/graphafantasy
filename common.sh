#!/bin/bash
set -o nounset
set -o errexit

parse_args() {
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --target|-t) TARGET_CHAR_ID="$2"; shift ;;
            --world|-w) WORLD="$2"; shift ;;
            *) echo "Unknown parameter: $1"; exit 1 ;;
        esac
        shift
    done
}

OPENAI_KEY=$(head -1 ~/.graphafantasy/OPENAI_KEY)
STABAI_KEY=$(head -1 ~/.graphafantasy/STABAI_KEY)
S3_BUCKET=$(head -1 ~/.graphafantasy/S3_BUCKET)

TARGET_CHAR_ID=""

parse_args "$@"

RAW_DB=worlds/${WORLD}/characters.tsv

REF_IMG_PATH=worlds/${WORLD}/00-ref_img
DB_PATH=worlds/${WORLD}/01-expanded-db/
DESC_IMG_PATH=worlds/${WORLD}/02-describe-ref_img/
STAB_IMG_PATH=worlds/${WORLD}/03-stability/
CARDS_PATH=worlds/${WORLD}/04-cards/
GRID_PATH=worlds/${WORLD}/05-grid/
VIDEO_PATH=worlds/${WORLD}/06-video/
TG_STICKERS_PATH=worlds/${WORLD}/08-tg-stickers/

mkdir -p ${DB_PATH}
mkdir -p ${DESC_IMG_PATH}
mkdir -p ${STAB_IMG_PATH}
mkdir -p ${CARDS_PATH}
mkdir -p ${GRID_PATH}
mkdir -p ${VIDEO_PATH}
mkdir -p ${TG_STICKERS_PATH}

find_last_db() {
    find ${DB_PATH} -type f -name 'characters*.tsv'|sort|tail -1
}

T=$(date +%s)
