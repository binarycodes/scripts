#!/bin/bash


usage(){
    cat <<EOF
    Usage:   $(basename $0) [options]

    Basic options:
    -d <device name>    device name to mount
EOF
}



while getopts ":d:" opt; do
    case $opt in
        d)
            DEVICE=${OPTARG}
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

if [[ -z $DEVICE ]]; then 
    DEVICE="sdd1"
fi



echo "mounting card device ... ${DEVICE}"
sudo mount /dev/${DEVICE} /media/sd_card
echo "transfering/updating pics ..."
rsync -ahSD --progress --recursive --update /media/sd_card/DCIM $HOME/camera
echo "checking and moving raw files if any ..."
find $HOME/camera/DCIM/ -name "*.NEF" -execdir mv '{}' $HOME/camera/raw/ \;
echo "unmounting card device ..."
sudo umount /media/sd_card
echo "card device unmounted. please remove the device..."

