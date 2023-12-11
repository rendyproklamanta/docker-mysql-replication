#!/bin/bash
# written by Hosein Yousefi <yousefi.hosein.o@gmail.com>
# GITHUB https://github.com/hosein-yousefii

# Automated script to replicate 2 instances of Mysql
# with REPLICATION_METHOD variable.
# FORINSTANCE:
# export REPLICATION_METHOD=master-slave

master-slave() {

	# load env file into the script's environment.
	source mysql.env
 
	echo
	echo Starting deploying...
	echo

	export TIMEZONE=${MYSQL_TIMEZONE:-'UTC'}

   export FIRST_HOST=${MYSQL_FIRST_HOST:-'mysql-master'}
	export SECOND_HOST=${MYSQL_SECOND_HOST:-'mysql-slave'}

	export FIRST_REPL_USER=${MYSQL_FIRST_REPLICATION_USER:-'repl'}
	export FIRST_REPL_PASSWORD=${MYSQL_FIRST_REPLICATION_PASSWORD:-'12345678910'}

	export FIRST_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-'12345678910'}
	export SECOND_ROOT_PASSWORD=${MYSQL_ROOT_SECOND_PASSWORD:-'12345678910'}

	export USER_PROXY_USERNAME=${MYSQL_USER_PROXY_USERNAME:-'proxy'}
   export USER_PROXY_PASSWORD=${MYSQL_USER_PROXY_PASSWORD:-'12345678910'}

	export USER_SUPER_USERNAME=${MYSQL_USER_SUPER_USERNAME:-'super'}
   export USER_SUPER_PASSWORD=${MYSQL_USER_SUPER_PASSWORD:-'12345678910'}

	#export IP_ADDR=${DOCKER0_IP:-$(ip a show dev docker0 |grep inet|awk '{print $2}'|awk -F\/ '{print $1}'|grep -v ::)}
   export IP_ADDR=0.0.0.0

	docker stack deploy --compose-file docker-compose.master-slave.yaml mysql

	echo
	echo waiting 60s for containers to be up and running...
	echo Implementing mysql master slave replication...
	sleep 60
	echo

	# Create user on master database.
	docker exec $(docker ps -q -f name=$FIRST_HOST) \
			mysql -u root --password=$FIRST_ROOT_PASSWORD \
			--execute="SET GLOBAL time_zone = '$TIMEZONE';\

			CREATE USER IF NOT EXISTS '$FIRST_REPL_USER'@'%' identified by '$FIRST_REPL_PASSWORD';\
			grant replication slave on *.* to '$FIRST_REPL_USER'@'%';\
                       
			CREATE USER IF NOT EXISTS '$USER_PROXY_USERNAME'@'%' identified by '$USER_PROXY_PASSWORD';\
			GRANT SELECT on *.* TO '$USER_PROXY_USERNAME'@'%';\

			CREATE USER IF NOT EXISTS '$MYSQL_USER_SUPER_USERNAME'@'%' identified by '$MYSQL_USER_SUPER_PASSWORD';\
			GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER_SUPER_USERNAME'@'%' WITH GRANT OPTION;\
			
			FLUSH PRIVILEGES;"

	# Get the log position and name.
	result=$(docker exec $(docker ps -q -f name=$FIRST_HOST) mysql -u root --password=$FIRST_ROOT_PASSWORD --execute="show master status;")
	log=$(echo $result|awk '{print $6}')
	position=$(echo $result|awk '{print $7}')

	# Connect slave to master.
	docker exec $(docker ps -q -f name=$SECOND_HOST) \
			mysql -u root --password=$SECOND_ROOT_PASSWORD \
			--execute="SET GLOBAL time_zone = '$TIMEZONE';\
			
			stop slave;\
			reset slave;\

			CREATE USER IF NOT EXISTS '$USER_PROXY_USERNAME'@'%' identified by '$USER_PROXY_PASSWORD';\
			GRANT SELECT on *.* TO '$USER_PROXY_USERNAME'@'%';\

			CREATE USER IF NOT EXISTS '$MYSQL_USER_SUPER_USERNAME'@'%' identified by '$MYSQL_USER_SUPER_PASSWORD';\
			GRANT SELECT on *.* TO '$MYSQL_USER_SUPER_USERNAME'@'%' WITH GRANT OPTION;\

			FLUSH PRIVILEGES;\

			CHANGE MASTER TO MASTER_HOST='$FIRST_HOST', MASTER_USER='$FIRST_REPL_USER', \
			MASTER_PASSWORD='$FIRST_REPL_PASSWORD', MASTER_LOG_FILE='$log', MASTER_LOG_POS=$position;\

			start slave;\
			SHOW SLAVE STATUS\G;"

	echo
	echo in case of any errors, check if your containers up and running, then rerun this script.
	echo
	echo The master is running on $IP_ADDR:3306,  
	echo The slave is running on $IP_ADDR:3307.
	echo
}

METHOD=${REPLICATION_METHOD:-'master-slave'}

case ${METHOD} in

        master-slave)
                master-slave
        ;;

        *)
                echo """

 Automated script to replicate 2 instances of Mysql

"""

        ;;

esac