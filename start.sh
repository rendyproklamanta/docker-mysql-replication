#!/bin/sh

mkdir -p /var/lib/mysql/data/master
mkdir -p /var/lib/mysql/data/slave

cd /var/lib/mysql

chmod +x remove.sh
./remove.sh

chmod +x mysql-deployment.master-slave.sh
./mysql-deployment.master-slave.sh