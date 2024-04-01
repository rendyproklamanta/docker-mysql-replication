#!/bin/sh

cd /var/lib/mysql/scripts

chmod +x remove.sh
./remove.sh

# Change master-slave or master-master
chmod +x start.master-slave.sh
./start.master-slave.sh

# Install PMA
cd /var/lib/mysql
docker stack deploy --compose-file docker-compose.pma.yaml mysql