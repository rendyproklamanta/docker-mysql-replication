#!/bin/sh

# change master-master / master-slave
cd master-slave/scripts

# Remove mysql services
docker stack rm mysql

# Run init.sh
chmod +x init.sh
./init.sh

# Install optional
cd ../../
docker stack deploy --compose-file docker-compose.pma.yaml mysql