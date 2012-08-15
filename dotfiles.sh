#!/bin/sh

DOTFILES_DIR="${HOME}/dotfiles"

usage () {
    cat <<EOF
Usage:   $(basename $0) [options]

 Basic options:
    -a [file]       add file from source to dotfiles
    -r [file]       remove file from dotfiles
    -s              sync dotfiles to source
    -h              show help
EOF
}

createDotfilesDir () {
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        echo -n "creating dotfiles directory $DOTFILES_DIR ... "
        mkdir -p "$DOTFILES_DIR"
        echo "done"
    else
        echo "using dotfiles directory $DOTFILES_DIR"
    fi
}


moveDotfilesToTarget () {
    local source="$HOME/${1}"
    local target="$DOTFILES_DIR/${1#.*}"
    echo "copying $source --> $target"
    if [[ -d "$1" ]]; then
        rsync --quiet --recursive --archive "$source" "$DOTFILES_DIR/"
        mv "$DOTFILES_DIR/$1" "$target"
    else
        mkdir -p "$(dirname "$target")"
        rsync --quiet --recursive --archive "$source" "$target"
    fi
}


removeDotfilesFromSource () {
    local source="$HOME/$1"
    if [[ -d "$source" ]]; then
        rm -rv "$source"
    elif [[ -f "$source" ]]; then
        rm -v "$source"
    fi
}

symlinkDotfiles () {
    local source="$DOTFILES_DIR/${1#.*}"
    local target="$HOME/${1}"
    echo -n "linking $source --> $target ..."
    ln -s "$source" "$target"
    echo "done"
}


addDotfiles () {
    createDotfilesDir "$1"
    moveDotfilesToTarget "$1"
    removeDotfilesFromSource "$1"
    symlinkDotfiles "$1"
}


while getopts ":a:r:s" opt; do
    case $opt in
        a)
            addDotfiles "$OPTARG"
            ;;
        r);;
        s);;
        \?)
            echo "invalid option: -$OPTARG" >&2
            usage
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            exit 1
            ;;
    esac
done
