#!/bin/zsh

PICTURE_PATH="$HOME/pictures/";
RAW_PATH="$HOME/camera/raw/";

SOURCE_KEEP_FILES=$(mktemp)
RAW_FILES=$(mktemp)

find $PICTURE_PATH -iregex "^/.*/nik_[0-9]*\.jpg$" -print0 \
    | xargs -0 basename -a \
    | tr '[:lower:]' '[:upper:]' \
    | tr '.JPG' '.NEF' \
    | sort -n > $SOURCE_KEEP_FILES

find $RAW_PATH -type f -print0 \
    | xargs -0 basename -a \
    | tr '[:lower:]' '[:upper:]' \
    | sort -n > $RAW_FILES

comm -13 $SOURCE_KEEP_FILES $RAW_FILES | sed "s|^|$RAW_PATH|" | xargs -r rm

rm $SOURCE_KEEP_FILES $RAW_FILES
