#!/bin/bash
set -o nounset
set -o errexit

source common.sh

aws --profile root s3 sync ${REF_IMG_PATH}/ s3://${S3_BUCKET}/${WORLD}/
