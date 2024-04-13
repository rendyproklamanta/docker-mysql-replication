#!/bin/sh

cd ../
mkdir -p data/master
mkdir -p data/backup
mkdir -p data/slave1

chmod -R 777 data

cd scripts
# Deploy master
chmod +x deploy.master.sh
./deploy.master.sh

# Deploy slave1
chmod +x deploy.slave1.sh
./deploy.slave1.sh

# Deploy proxysql
cd ../proxysql
docker stack deploy --compose-file docker-compose.yaml mysql