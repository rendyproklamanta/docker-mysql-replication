#!/bin/bash

master-master() {

    # load env file into the script's environment.
    source ./mysql.env
    
    echo
    echo starting deploying...
	echo

	export TIMEZONE=${TIMEZONE:-'UTC'}

    export HOST_MASTER=mysql-master
    export HOST_SLAVE1=mysql-master2

    export FIRST_REPL_USER=${REPL_USER:-'repl-master1'}
    export SECOND_REPL_USER=${MYSQL_SECOND_REPLICATION_USER:-'repl-master2'}

    export FIRST_REPL_PASSWORD=${REPL_PASSWORD:-'12345678910'}
    export SECOND_REPL_PASSWORD=${REPL2_PASSWORD:-'12345678910'}

    export FIRST_ROOT_PASSWORD=${MASTER_ROOT_PASSWORD:-'12345678910'}
    export SECOND_ROOT_PASSWORD=${MYSQL_ROOT_SECOND_PASSWORD:-'12345678910'}

    export USER_PROXY_USERNAME=${MYSQL_USER_PROXY_USERNAME:-'proxy'}
    export USER_PROXY_PASSWORD=${MYSQL_USER_PROXY_PASSWORD:-'12345678910'}

    export USER_SUPER_USERNAME=${USER_SUPER_USERNAME:-'super'}
    export USER_SUPER_PASSWORD=${USER_SUPER_PASSWORD:-'12345678910'}

    #export IP_ADDR=${DOCKER0_IP:-$(ip a show dev docker0 |grep inet|awk '{print $2}'|awk -F\/ '{print $1}'|grep -v ::)}
    export IP_ADDR=0.0.0.0

    cd /var/lib/mysql
	docker stack deploy --compose-file docker-compose.master-master.yaml mysql

    echo
    echo waiting 30s for containers to be up and running...
	echo Implementing mysql master master replication...
    sleep 60
    echo

    # Create user database.
    docker exec $(docker ps -q -f name=$HOST_MASTER) \
        mysql -u root --password=$FIRST_ROOT_PASSWORD \
        --execute="CREATE USER IF NOT EXISTS '$FIRST_REPL_USER'@'%' identified by '$FIRST_REPL_PASSWORD';\
        grant replication slave on *.* to '$FIRST_REPL_USER'@'%';\

        CREATE USER IF NOT EXISTS '$USER_PROXY_USERNAME'@'%' identified by '$USER_PROXY_PASSWORD';\
        GRANT SELECT on *.* TO '$USER_PROXY_USERNAME'@'%';\

        CREATE USER IF NOT EXISTS '$USER_SUPER_USERNAME'@'%' identified by '$USER_SUPER_PASSWORD';\
        GRANT ALL PRIVILEGES ON *.* TO '$USER_SUPER_USERNAME'@'%' WITH GRANT OPTION;\

        flush privileges;"

    docker exec $(docker ps -q -f name=$HOST_SLAVE1) \
        mysql -u root --password=$SECOND_ROOT_PASSWORD \
        --execute="CREATE USER IF NOT EXISTS '$SECOND_REPL_USER'@'%' identified by '$SECOND_REPL_PASSWORD';\
        grant replication slave on *.* to '$SECOND_REPL_USER'@'%';\

        CREATE USER IF NOT EXISTS '$USER_PROXY_USERNAME'@'%' identified by '$USER_PROXY_PASSWORD';\
        GRANT SELECT on *.* TO '$USER_PROXY_USERNAME'@'%';\

        CREATE USER IF NOT EXISTS '$USER_SUPER_USERNAME'@'%' identified by '$USER_SUPER_PASSWORD';\
        GRANT ALL PRIVILEGES ON *.* TO '$USER_SUPER_USERNAME'@'%' WITH GRANT OPTION;\
                    
        flush privileges;"


    # Get the log position and name.
    master1_result=$(docker exec $(docker ps -q -f name=$HOST_MASTER) mysql -u root --password=$FIRST_ROOT_PASSWORD --execute="show master status;")
    master1_log=$(echo $master1_result|awk '{print $6}')
    master1_position=$(echo $master1_result|awk '{print $7}')

    master2_result=$(docker exec $(docker ps -q -f name=$HOST_SLAVE1) mysql -u root --password=$SECOND_ROOT_PASSWORD --execute="show master status;")
    master2_log=$(echo $master2_result|awk '{print $6}')
    master2_position=$(echo $master2_result|awk '{print $7}')

    # Setup master-master
    docker exec $(docker ps -q -f name=$HOST_SLAVE1) \
        mysql -u root --password=$SECOND_ROOT_PASSWORD \
        --execute="SET GLOBAL time_zone = '$TIMEZONE';\

        stop slave;\
        reset slave;\

        CHANGE MASTER TO MASTER_HOST='$HOST_MASTER', MASTER_USER='$FIRST_REPL_USER', \
        MASTER_PASSWORD='$FIRST_REPL_PASSWORD', MASTER_LOG_FILE='$master1_log', MASTER_LOG_POS=$master1_position;\
        
        start slave;\
        SHOW SLAVE STATUS\G;"

    docker exec $(docker ps -q -f name=$HOST_MASTER) \
        mysql -u root --password=$FIRST_ROOT_PASSWORD \
        --execute="SET GLOBAL time_zone = '$TIMEZONE';\
        
        stop slave;\
        reset slave;\

        CHANGE MASTER TO MASTER_HOST='$HOST_SLAVE1', MASTER_USER='$SECOND_REPL_USER', \
        MASTER_PASSWORD='$SECOND_REPL_PASSWORD', MASTER_LOG_FILE='$master2_log', MASTER_LOG_POS=$master2_position;\

        start slave;\
        SHOW SLAVE STATUS\G;"

	sleep 2
	echo
	echo ###################	SECOND status

    docker exec $(docker ps -q -f name=$HOST_SLAVE1) \
        mysql -u root --password=$SECOND_ROOT_PASSWORD \
        --execute="SHOW SLAVE STATUS\G;"

	sleep2
	echo
	echo ###################	FIRST status

    docker exec $(docker ps -q -f name=$HOST_MASTER) \
        mysql -u root --password=$FIRST_ROOT_PASSWORD \
        --execute="SHOW SLAVE STATUS\G;"


	sleep 2
    echo
    echo in case of any errors, check if your containers up and running, then rerun this script.
    echo
    echo The master1 is running on $IP_ADDR:3306,
    echo The master2 is running on $IP_ADDR:3307.
    echo

}

METHOD=${REPLICATION_METHOD:-'master-master'}

case ${METHOD} in

        master-master)
                master-master
        ;;

        *)
                echo """

 Automated script to replicate 2 instances of Mysql

"""

        ;;

esac