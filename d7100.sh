#!/bin/zsh

echo "mounting card device ..."
sudo mount /dev/sdd1 /media/sd_card
echo "transfering/updating pics ..."
rsync --progress --recursive --update /media/sd_card/DCIM $HOME/camera
echo "checking and moving raw files if any ..."
find $HOME/camera/DCIM/ -name "*.NEF" -execdir mv '{}' $HOME/camera/raw/ \;
echo "unmounting card device ..."
sudo umount /media/sd_card
echo "card device unmounted. please remove the device..."
