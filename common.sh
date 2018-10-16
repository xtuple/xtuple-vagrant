#!/bin/sh

# fix for error message from Vagrant, but it may still show up
if $(tty -s); then
  mesg n
fi

PROG=${PROG:-$(basename $0)}

XTUPLEDIR=$HOME/dev/xtuple
# let .nvmrc determine NODEVER unless we have a reason to override
NODEVER=
PGVER=${PGVER:-9.5}
QTVER=5
WARNINGS=
WINDOWSHOST=false

cdir() {
  echo "Changing directory to $1"
  cd $1
}

die() {
  local RESULT=63
  if [ $# -gt 0 -a $(( $1 + 0 )) -ne 0 ] ; then
    RESULT=$1
    shift
  fi
  [ $# -gt 0 ] && echo $*
  exit $RESULT
}

sicken() {
  WARNINGS="$WARNINGS;$@"
}

usage() {
  echo $PROG -h
  echo $PROG [ -p postgresversion ] [ -q qtversion ] [ -w ]
  echo
  echo "-w      running on a Windows host"
}

while getopts "hn:p:q:w" OPT ; do
  case $OPT in
    h) usage
       exit 0
       ;;
    n) NODEVER=$OPTARG  ;;
    p) PGVER=$OPTARG    ;;
    q) QTVER=$OPTARG    ;;
    w) WINDOWSHOST=true ;;
  esac
done

sudo apt-get install --assume-yes git
