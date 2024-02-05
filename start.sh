#!/bin/sh

cd /var/lib/mysql
mkdir -p data/master
mkdir -p data/slave
mkdir -p data/backup

chmod +x remove.sh
./remove.sh

chmod +x mysql-deployment.master-slave.sh
./mysql-deployment.master-slave.sh
