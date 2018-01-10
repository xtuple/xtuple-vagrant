#!/bin/bash

PROG=${PROG:-$(basename $0)}
VAGRANTPREFIX=/vagrant
if [ ! -e $VAGRANTPREFIX/common.sh ] ; then
  VAGRANTPREFIX=.
fi
source $VAGRANTPREFIX/common.sh
