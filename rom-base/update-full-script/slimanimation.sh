#!/bin/bash

animationzip="$1"

if [ -f "$animationzip" ]; then
    newname="new-$(basename $animationzip)"
    echo "slim animation $animationzip"
    mkdir tmp_animation
    unzip "$animationzip" -d tmp_animation/

    cd tmp_animation/
    for part in $(ls -d part*); do
        prnt='yes'
        for file in $(ls $part/); do
            if [[ $prnt == 'yes' ]]; then
                echo "hold $part/$file."
                prnt='no'
            else
                rm -v $part/$file
                prnt='yes'
            fi
        done
    done

    read -p 'Edit desc.txt [y/n]' ANSW
    if [ $ANSW == y -o $ANSW == Y ]; then
        nano desc.txt
    fi

    zip -r -X -0 ../$newname part*/*.* desc.txt
    cd ..
    rm -r tmp_animation/
else
    echo "usage: $0 animation-zip-file"
    echo "$animationzip not found."
    exit 1
fi
