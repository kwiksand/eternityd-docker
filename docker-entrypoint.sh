#!/bin/bash

set -e
ETERNITY_DATA=/home/eternity/.eternity
CONFIG_FILE=eternity.conf
EXEC_CM=eternityd

if [ -z $1 ] || [ "$1" == "eternityd" ] || [ $(echo "$1" | cut -c1) == "-" ]; then
  cmd=eternityd
  shift

  if [ ! -d $ETERNITY_DATA ]; then
    echo "$0: DATA DIR ($ETERNITY_DATA) not found, please create and add config.  exiting...."
    exit 1
  fi

  if [ ! -f $ETERNITY_DATA/$CONFIG_FILE ]; then
    echo "$0: eternityd config ($ETERNITY_DATA/$CONFIG_FILE) not found, please create.  exiting...."
    exit 1
  fi

  chmod 700 "$ETERNITY_DATA"
  chown -R eternity "$ETERNITY_DATA"

  if [ -z $1 ] || [ $(echo "$1" | cut -c1) == "-" ]; then
    echo "$0: assuming arguments for eternityd"

    set -- $cmd "$@" -datadir="$ETERNITY_DATA"
  else
    set -- $cmd -datadir="$ETERNITY_DATA"
  fi

  exec gosu eternity "$@"
elif [ "$1" == "eternity-cli" ] || [ "$1" == "eternity-tx" ]; then

  exec gosu eternity "$@"
else
  echo "This entrypoint will only execute eternityd, eternity-cli and eternity-tx"
fi
