#!/bin/sh

cd /var/lib/mysql
mkdir -p data/master
mkdir -p data/slave
mkdir -p data/backup

chmod -R 777 data

cd /var/lib/mysql/cmd
chmod +x deploy.master-slave.sh
./deploy.master-slave.sh

cd /var/lib/mysql/proxysql/master-slave
docker stack deploy --compose-file docker-compose.yaml mysql