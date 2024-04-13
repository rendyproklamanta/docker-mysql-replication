#!/bin/bash

# load env file into the script's environment.
source ./mysql.env

echo
echo Starting deploying SLAVE2...
echo

cd ../
docker stack deploy --compose-file docker-compose.SLAVE2.yaml mysql

echo Host : $HOST_SLAVE2
echo waiting 10s for master to be up and running...
echo Implementing slave replication...
sleep 10
echo

# Get the log position and name from master
result=$(docker exec $(docker ps -q -f name=$HOST_MASTER) mysql -u root --password=$MASTER_ROOT_PASSWORD --execute="show master status;")
log=$(echo $result|awk '{print $6}')
position=$(echo $result|awk '{print $7}')

# Connect slave to master.
docker exec $(docker ps -q -f name=$HOST_SLAVE2) \
		mysql -u root --password=$SLAVE2_ROOT_PASSWORD \
		--execute="SET GLOBAL time_zone = '$TIMEZONE';\
		
		stop slave;\
		reset slave;\

		CHANGE MASTER TO MASTER_HOST='$HOST_MASTER', MASTER_USER='$REPL_USER', \
		MASTER_PASSWORD='$REPL_PASSWORD', MASTER_LOG_FILE='$log', MASTER_LOG_POS=$position;\

		start slave;\
		SHOW SLAVE STATUS\G;"

echo
echo The SLAVE2 is running on port 3301
echo