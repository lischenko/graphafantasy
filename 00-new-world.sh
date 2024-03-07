#!/bin/bash
set -o nounset
set -o errexit

WORLD=worlds/$1
mkdir -p ${WORLD}

PROTO_WRLD=worlds/sample

cp -nr ${PROTO_WRLD}/00-ref_img                        ${WORLD}/
cp -n  ${PROTO_WRLD}/characters.tsv                    ${WORLD}/
cp -n  ${PROTO_WRLD}/prompt-01-enrich-table.txt        ${WORLD}/
cp -n  ${PROTO_WRLD}/prompt-02-describe-ref-images.txt ${WORLD}/
cp -n  ${PROTO_WRLD}/prompt-03-char-stability.txt      ${WORLD}/
cp -n  ${PROTO_WRLD}/03-image-prep.sh                  ${WORLD}/
cp -n  ${PROTO_WRLD}/03-stabai-call.sh                 ${WORLD}/
cp -nr ${PROTO_WRLD}/templates                         ${WORLD}/
