#!/bin/sh

cd /var/lib/mysql
mkdir -p data/master1
mkdir -p data/master2
mkdir -p data/backup

chmod -R 777 data

cd /var/lib/mysql/cmd
chmod +x deploy.master-master.sh
./deploy.master-master.sh

cd /var/lib/mysql/proxysql/master-master
docker stack deploy --compose-file docker-compose.yaml mysql