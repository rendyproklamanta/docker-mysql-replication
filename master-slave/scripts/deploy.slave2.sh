#!/bin/bash

# load env file into the script's environment.
source env/master.sh
source env/slave2.sh
source env/user.sh

echo
echo Starting deploying slave2...
echo

cd ../
docker stack deploy --compose-file docker-compose.slave2.yaml mysql

echo Host : $HOST_SLAVE2
echo waiting 60s for master to be up and running...
echo Implementing slave replication...
sleep 60
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

		CREATE USER IF NOT EXISTS '$USER_MONITOR_USERNAME'@'%' identified by '$USER_MONITOR_PASSWORD';\
		GRANT USAGE, REPLICATION CLIENT ON *.* TO '$USER_MONITOR_USERNAME'@'%';\

		CREATE USER IF NOT EXISTS '$USER_SUPER_USERNAME'@'%' identified by '$USER_SUPER_PASSWORD';\
		GRANT SELECT ON *.* TO '$USER_SUPER_USERNAME'@'%';\

		FLUSH PRIVILEGES;\

		CHANGE MASTER TO MASTER_HOST='$HOST_MASTER', MASTER_USER='$REPL_USERNAME', \
		MASTER_PASSWORD='$REPL_PASSWORD', MASTER_LOG_FILE='$log', MASTER_LOG_POS=$position;\

		start slave;\
		SHOW SLAVE STATUS\G;"

echo
echo The slave2 is running on port 3301
echo