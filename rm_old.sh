#!/bin/sh

cd `dirname $0`
find tmp/icons/* -atime +3 2> /dev/null | xargs rm -f
