#!/bin/bash

# load env file into the script's environment.
source env/user.sh
source env/master.sh

echo
echo Starting deploying master...
echo

cd ../
docker stack deploy --compose-file docker-compose.master.yaml mysql

echo Host : $HOST_MASTER
echo waiting 60s for containers to be up and running...
echo Implementing master replication...
sleep 60
echo

# Create user on master database.
docker exec $(docker ps -q -f name=$HOST_MASTER) \
		mysql -u root --password=$MASTER_ROOT_PASSWORD \
		--execute="SET GLOBAL time_zone = '$TIMEZONE';\

		CREATE USER IF NOT EXISTS '$REPL_USERNAME'@'%' identified by '$REPL_PASSWORD';\
		grant replication slave on *.* to '$REPL_USERNAME'@'%';\			

		CREATE USER IF NOT EXISTS '$USER_MONITOR_USERNAME'@'%' identified by '$USER_MONITOR_PASSWORD';\
		GRANT USAGE, REPLICATION CLIENT ON *.* TO '$USER_MONITOR_USERNAME'@'%';\

		CREATE USER IF NOT EXISTS '$USER_SUPER_USERNAME'@'%' identified by '$USER_SUPER_PASSWORD';\
		GRANT ALL PRIVILEGES ON *.* TO '$USER_SUPER_USERNAME'@'%' WITH GRANT OPTION;\
		
		FLUSH PRIVILEGES;"

echo
echo The master is running on port 3300
echo