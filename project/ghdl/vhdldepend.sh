#!/bin/sh

#-------------------------------------------------------------------------------
# Copyright (C) 2018 Dominik Salvet
# SPDX-License-Identifier: MIT
#-------------------------------------------------------------------------------

target=$(echo "$1" | sed -e 's|.*/||;s/\.[^\.]*$/.o/;s|^|'"$2"'|;')

command1='/^\s*use/!d;s/use//;s/\s*//g;/^ieee\|^std/d;s/\;$//;s/\.all$//;s/^.*\.//;s/^.*/&.o/;s|^|'"$2"'|;'
command2=':next;$bdone;N;bnext;:done;s/\n/ /g;s|^|'"$target"': |;'

sed -e "$command1" "$1" |
sed -e "$command2"
