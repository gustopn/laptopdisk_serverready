#!/bin/bash
scriptdir="`dirname $0`"
scriptdir="`realpath "$scriptdir"`"
hdparmbin="/usr/sbin/hdparm"
alldisks_list="`"$scriptdir/list_alldisks.sh"`"
currentuserid=`id -u`

if [ ! -x "$hdparmbin" ]
then \
  echo "ERROR: hdparm not found"
  exit 1
fi

for disk_instance in $alldisks_list
do \
  instancedesc=""
  if [ "$currentuserid" -eq 0 ]
  then \
    instancedesc="`"$hdparmbin" -I "$disk_instance" | grep -e "Model Number:" -e "Serial Number:"`"
  else \
    instancedesc="`sudo "$hdparmbin" -I "$disk_instance" | grep -e "Model Number:" -e "Serial Number:"`"
  fi
  instancemodel="`echo "$instancedesc"  | grep "Model Number:"  | awk -F":" '{ print $2 }' | awk '{ sub(/^[ \t\r\n]+/, "", $0); sub(/[ \t\r\n]+$/, "", $0); print $0 }'`"
  instanceserial="`echo "$instancedesc" | grep "Serial Number:" | awk -F":" '{ print $2 }' | awk '{ sub(/^[ \t\r\n]+/, "", $0); sub(/[ \t\r\n]+$/, "", $0); print $0 }'`"
  currentapmlevel=""
  if [ "$currentuserid" -eq 0 ]
  then \
    currentapmlevel=`"$hdparmbin" -B "$disk_instance" | grep APM_level | awk '{ print $NF }'`
  else \
    currentapmlevel=`sudo "$hdparmbin" -B "$disk_instance" | grep APM_level | awk '{ print $NF }'`
  fi
  currentsavingstate=`echo $currentapmlevel | awk '{ if ( int($NF) < 254 && $NF != "off" ) { print "SAVING" } }'`
  if [ -n "$currentsavingstate" ]
  then \
    if [ "$currentuserid" -eq 0 ]
    then \
      "$hdparmbin" -B 255 "$disk_instance" || echo "WARNING: $disk_instance failed to turn off APM"
    else \
      sudo "$hdparmbin" -B 255 "$disk_instance" || echo "WARNING: $disk_instance failed to turn off APM"
    fi
  else \
    printf "%b (%-23s - %-20s) %b\n" "Skipping $disk_instance" "${instancemodel}" "${instanceserial}" "APM level: $currentapmlevel"
  fi
done
