#!/bin/bash
# Source this file to fix the windows path not to have parens
# Assume one has the mount,
# "C:/Program Files (x86)" /ProgramFilesX86 ntfs binary 0 0
echo $PATH >/tmp/path$$.txt
cat >/tmp/path$$.sed <<EOF
s/:/:\\
/g
s?cygdrive/c/Program Files (x86)?ProgramFilesX86?g
EOF
sed -f /tmp/path$$.sed </tmp/path$$.txt >/tmp/path$$.tmp
grep -v '(' /tmp/path$$.tmp | tr -d '\n' >/tmp/path$$.txt
PATH=`cat /tmp/path$$.txt`
rm /tmp/path$$.tmp /tmp/path$$.txt /tmp/path$$.sed
echo PATH = $PATH
