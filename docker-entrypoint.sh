#!/bin/sh
set -e
ETERNITY_DATA=/home/eternity/.eternity
cd /home/eternity/eternityd

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for eternityd"

  set -- eternityd "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "eternityd" ]; then
  mkdir -p "$ETERNITY_DATA"
  chmod 700 "$ETERNITY_DATA"
  chown -R eternity "$ETERNITY_DATA"

  echo "$0: setting data directory to $ETERNITY_DATA"

  set -- "$@" -datadir="$ETERNITY_DATA"
fi

if [ "$1" = "eternityd" ] || [ "$1" = "eternity-cli" ] || [ "$1" = "eternity-tx" ]; then
  echo
  exec gosu eternity "$@"
fi

echo
exec "$@"
