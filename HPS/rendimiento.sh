#!/bin/bash
#Reiniciando Mysql
sudo /etc/init.d/mysql restart
sleep 5
#Obteniendo datos iniciales
cat /proc/meminfo | grep MemTotal >> rend1.txt
cat /proc/meminfo | grep Active: >> rend1.txt
ps | wc -l >> rend1.txt
ps -aux |grep /mysqld >> rend1.txt
#Habilitando consulta en paralelo
./consultar.sh &
sleep 20
#Obteniendo datos mientras se está consultando
cat /proc/meminfo | grep MemTotal >> rend1.txt
cat /proc/meminfo | grep Active: >> rend1.txt
ps | wc -l >> rend1.txt
ps -aux |grep /mysqld >> rend1.txt
#Terminando consulta
pkill consultar.sh
sleep 5
#Reiniciando Mysql
sudo /etc/init.d/mysql restart
sleep 5
#Obteniendo datos luego de consulta
cat /proc/meminfo | grep MemTotal >> rend1.txt
cat /proc/meminfo | grep Active: >> rend1.txt
ps | wc -l >> rend1.txt
ps -aux |grep /mysqld >> rend1.txt
