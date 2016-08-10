#!/bin/bash

myfull=${1:-./new-update-full-zip-dir}
offical=${2:-./PD1304CL_A_1.19.3-update-full}

find $offical -type f -exec md5sum {} \; | sed "s|${offical}||"|sort -k 2 > offical.list
find $myfull -type f -exec md5sum {} \; | sed "s|${myfull}||"|sort -k 2 > myfull.list

diff -Nu offical.list myfull.list > compare.result

rm offical.list myfull.list
