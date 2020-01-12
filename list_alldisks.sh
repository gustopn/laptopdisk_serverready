#!/bin/bash
lsscsibin="/usr/bin/lsscsi"
if [ ! -x "$lsscsibin" ]
then \
  echo "ERROR: lsscsi not found"
  exit 1
fi

"$lsscsibin" | awk '{ if ( $2 == "disk" && $3 == "ATA" ) { print $NF } }'
