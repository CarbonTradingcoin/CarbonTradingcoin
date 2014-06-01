#!/bin/bash
# create multiresolution windows icon
ICON_SRC=../../src/qt/res/icons/carbonemissiontradecoin.png
ICON_DST=../../src/qt/res/icons/carbonemissiontradecoin.ico
convert ${ICON_SRC} -resize 16x16 carbonemissiontradecoin-16.png
convert ${ICON_SRC} -resize 32x32 carbonemissiontradecoin-32.png
convert ${ICON_SRC} -resize 48x48 carbonemissiontradecoin-48.png
convert carbonemissiontradecoin-16.png carbonemissiontradecoin-32.png carbonemissiontradecoin-48.png ${ICON_DST}

