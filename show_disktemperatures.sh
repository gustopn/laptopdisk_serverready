#!/bin/bash
scriptdir="`dirname $0`"
scriptdir="`realpath "$scriptdir"`"
smartctlbin="/usr/sbin/smartctl"
alldisks_list="`"$scriptdir/list_alldisks.sh"`"
currentuserid=`id -u`

if [ ! -x "$smartctlbin" ]
then \
  echo "ERROR: smartctl not found"
  exit 1
fi

for disk_instance in $alldisks_list
do \
  instance_allinfo=""
  if [ "$currentuserid" -eq 0 ]
  then \
    instance_allinfo="`"$smartctlbin" -iA "$disk_instance"`"
  else \
    instance_allinfo="`sudo "$smartctlbin" -iA "$disk_instance"`"
  fi
  instance_desc="`echo "$instance_allinfo" | grep -e "Device Model:" -e "Serial Number:"`"
  instance_model="`echo "$instance_desc" | grep "Device Model:" | awk -F":" '{ print $2 }' | awk '{ sub(/^[ \t\r\n]+/, "", $0); sub(/[ \t\r\n]+$/, "", $0); print $0 }'`"
  instance_serial="`echo "$instance_desc" | grep "Serial Number:" | awk -F":" '{ print $2 }' | awk '{ sub(/^[ \t\r\n]+/, "", $0); sub(/[ \t\r\n]+$/, "", $0); print $0 }'`"
  instance_temperature="`echo "$instance_allinfo" | awk '{ if ( int($1) && $2 == "Temperature_Celsius" ) { print $10 } }'`"
  printf "%b (%-23s - %-20s) %b degC\n" "$disk_instance" "$instance_model" "$instance_serial" "$instance_temperature"
done
