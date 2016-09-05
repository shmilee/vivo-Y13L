#!/bin/bash

usage() {
    echo "Usage:"
    echo "  $0 <path/to/system/dir>"
    exit 0
}

system_dir="$1"

[[ x"$1" == x ]] && usage

if [ ! -d "$system_dir" ]; then
    echo "$system_dir not found."
    usage
    exit 1
fi
if [ ! -d "$system_dir"/app -o  ! -d "$system_dir"/etc -o ! -d "$system_dir"/media/audio/notifications ]; then
    echo "$system_dir is not a rom/system/ directory."
    usage
    exit 1
fi

install -m644 -v ./EagerRemix.m4a "$system_dir"/media/audio/notifications/EagerRemix.m4a
install -m644 -v ./SanguineRemix.m4a "$system_dir"/media/audio/notifications/SanguineRemix.m4a

unzip ./February-08-2016-hosts.zip HOSTS
mv -i -v HOSTS "$system_dir"/etc/hosts
