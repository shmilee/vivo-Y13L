#!/sbin/sh

list=$1

if [ -f $list ]; then
    for file in `cat $list`; do
        echo "- remove file: $file"
        rm -f $file
    done
    echo "- remove file: $list"
    rm -f $list
else
    echo "- !!! list file '$list' not found."
fi
