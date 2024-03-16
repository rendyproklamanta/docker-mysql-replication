#!/bin/sh

cd /var/lib/mysql
mkdir -p data/master1
mkdir -p data/master2
mkdir -p data/backup

chmod -R 777 data
chmod +x remove.sh
./remove.sh

chmod +x mysql-deployment.master-master.sh
./mysql-deployment.m