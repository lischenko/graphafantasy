#!/bin/bash
set -o nounset
set -o errexit

source common.sh

montage -tile 2x3 -geometry +0+0 ${CARDS_PATH}/*.png ${GRID_PATH}/grid.png
#montage -tile 3x4 -geometry +0+0 ${CARDS_PATH}/*.png ${GRID_PATH}/grid.png
