#!/bin/bash
set -o nounset
set -o errexit

source common.sh

req=$(jq -n --rawfile prompt worlds/${WORLD}/prompt-01-enrich-table.txt --rawfile rawdb ${RAW_DB} '{"model": "gpt-4-1106-preview", "messages": [{"role": "user", "content": "\( $rawdb ). \( $prompt )"}]}')
echo $req

resp=$(curl https://api.openai.com/v1/chat/completions \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer ${OPENAI_KEY}" \
     -d "$req")

echo $resp | jq -r '.choices[0].message.content' | tee ${DB_PATH}/characters01-$(date +%s).tsv

