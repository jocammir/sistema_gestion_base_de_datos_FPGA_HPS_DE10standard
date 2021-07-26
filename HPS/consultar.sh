#!/bin/bash
while :
do
  mysql -u root -proot123 -D "telemetry_greenhouse" -e "select soil,node_id from measures limit 10" > resultado.txt
#./rendimiento.sh
#sleep 1
done
#cat /proc/meminfo | grep MemTotal
#cat /proc/meminfo | grep Active:
#grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%"}'
