#!/bin/bash

# ------------------------------------------------------------------------------------
# Copy all files from a playlist to a dest folder
# ------------------------------------------------------------------------------------
if [ "$#" != 2 ]; then
    echo usage $0 playlist.m3u dest-dir
    exit 1
fi

if [ ! -d "$2" ]; then
    mkdir $2
    echo Creating directory `pwd`"/"$2
fi

if [ -z "$1" ]; then
    echo  $1 is not a valid file
    exit 2
fi

cat "$1" | grep -v '#' | while read i; do sudo rsync --update -h --recursive "${i}" "$2" ; echo "${i}"; done
