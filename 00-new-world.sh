#!/bin/bash
set -o nounset
set -o errexit

WORLD=worlds/$1
mkdir -p ${WORLD}

PROTO_WRLD=sample


cp -n worlds/${PROTO_WRLD}/prompt-01-enrich-table.txt        ${WORLD}/
cp -n worlds/${PROTO_WRLD}/prompt-02-describe-ref-images.txt ${WORLD}/
cp -n worlds/${PROTO_WRLD}/prompt-03-char-stability.txt      ${WORLD}/

cp -nr worlds/${PROTO_WRLD}/templates      ${WORLD}/

if [ -f worlds/${PROTO_WRLD}/03-image-prep.sh ]; then
    cp -n worlds/${PROTO_WRLD}/03-image-prep.sh ${WORLD}/
fi

# characters and images are shared
pushd ${WORLD}/
ln -s ../${PROTO_WRLD}/00-ref_img 00-ref_img
ln -s ../${PROTO_WRLD}/characters.tsv characters.tsv
popd
