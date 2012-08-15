#!/bin/bash
# Simple Desktops Mass Downloader

# Parsing parameters
if [[ $# < 2 ]]; then
    echo "Usage: simpledesktops.sh <destination> <pages> [<normal|update|replace>]"
    exit
fi

destination=$1
if [ ! -d "$destination" ]; then
    mkdir "$destination"
fi

pageseq=$2
if [ -z $(echo "$pageseq" | grep -) ]; then
    pageseq="1 $pageseq"
else
    pageseq=${pageseq/-/ }
fi

if [[ $# > 2 ]]; then
mode=$3
else
    mode="normal"
fi

# Main loop
updated=false
total=0
for pagenum in `seq $pageseq`
do
    echo "Fetching links from page $pagenum..."
    page=$(curl -s "http://simpledesktops.com/browse/$pagenum/" --compress | grep "295x184_q100.png")
    urls=$(echo "$page" | sed -r 's/(.+)src="(.+)\.295x184_q100.png(.+)/\2/')
    titles=$(echo "$page" | sed -r 's/(.+)title="(.+)" alt="(.+)/\2/')
    imgcount=$(echo "$titles" | wc -l)
    echo "Page $pagenum contains $imgcount images."

    # Checking for already existing images
    if [ $mode == "replace" ]; then
        titlestodl=$titles
        urlstodl=$urls
    else
        urlstodl=""
        titlestodl=""
        for img in `seq 1 $imgcount`
        do
            currenturl=$(echo "$urls" | head -n $img | tail -n 1)
            currenttitle=$(echo "$titles" | head -n $img | tail -n 1)

            if [[ -z $(find "$destination" | grep "/$currenttitle.png") ]]; then
                urlstodl="$urlstodl
                $currenturl"
                titlestodl="$titlestodl
                $currenttitle"
            else
                echo "$currenttitle already exists."
                if [ $mode == "update" ]; then
                    updated=true
                    break
                fi
            fi
        done
    fi
    titlestodl=$(echo "$titlestodl" | sed -r 's/^[\t]*//' | sed -r '/^[\t]*$/d')
    urlstodl=$(echo "$urlstodl" | sed -r 's/^[\t]*//' | sed -r '/^[\t]*$/d')
    todlcount=$(echo "$titlestodl" | wc -l)

    # Downloading images
    if [ $todlcount == 0 ]; then
        echo "No images to download from page $pagenum."
    else
        echo "Downloading $todlcount images from page $pagenum..."
        for img in `seq 1 $todlcount`
        do
            currenturl=$(echo "$urlstodl" | head -n $img | tail -n 1)
            currenttitle=$(echo "$titlestodl" | head -n $img | tail -n 1)
            if [[ $currenttitle != "" ]]; then
                echo "Downloading $currenttitle..."
                curl -o "/tmp/$currenttitle.png" -# $currenturl
                mv "/tmp/$currenttitle.png" "$destination/$currenttitle.png"
                total=$(expr $total + 1)
            fi
        done
    fi

    if [ $updated == true ]; then
        echo "Done updating. There is $total new images in $destination."
        exit
    fi
done

# Shit happens
if [ -f "$destination/.png" ]; then
    rm "$destination/.png"
fi

echo "Finished downloading $total images from $pageseq pages in $destination."
