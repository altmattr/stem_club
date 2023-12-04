#!/bin/bash

if [ $(id -u) -ne 0 ]; then
  printf "This script should be run as root. Try 'sudo ./install.sh'\n"
  exit 1
fi

git clone https://github.com/altmattr/stem_club.git

cd stem_club

sudo ./setup.sh