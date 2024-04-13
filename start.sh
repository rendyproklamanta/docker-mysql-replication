#!/bin/sh

# change master-master / master-slave
cd master-slave/scripts

# Remove mysql services
docker stack rm mysql

chmod +x init.sh
./init.sh

# Install compose
cd ../../
docker stack deploy --compose-file docker-compose.pma.yaml mysql
docker stack deploy --compose-file docker-compose.cron-backup.yaml mysql