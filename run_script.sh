#!/bin/bash

PATH=$PATH:/usr/local/bin
. /usr/local/lib/rvm

DIR=/data/test/dScript/current
cd $DIR
rvm use 2.1.5
mkdir -p "$DIR/processes/$1/log/"
./run.rb "$1" >> "$DIR/processes/$1/log/script.log" 2>&1