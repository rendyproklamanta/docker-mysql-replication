# MySQL-replication-docker-stack
MYSQL automated master-master, master-slave docker compose replication


[![GitHub license](https://img.shields.io/github/license/hosein-yousefii/MySQL-replication-docker-stack)](https://github.com/hosein-yousefii/MySQL-replication-docker-stack/blob/master/LICENSE)
![LinkedIn](https://shields.io/badge/style-hoseinyousefii-black?logo=linkedin&label=LinkedIn&link=https://www.linkedin.com/in/hoseinyousefi)


Implementing a master-master or master-slave mysql replication is always a challenge. I Automated this process by using docker containers.

## What is MYSQL?

MySQL Database Service is a fully managed database service to deploy cloud-native applications.

### What is master-slave replication?

MySQL replication is the process by which a single data set, stored in a MySQL database, will be live-copied to a second server. This configuration, called “master-slave” replication, is a typical setup.

### What is master-master replication?

MYSQL master-master replication allows data to be copied from either server to the other one. This subtle but important difference allows us to perform mysql read or writes from either server. This configuration adds redundancy and increases efficiency when dealing with accessing the data.

# Get started with master-slave:

There are several variables which is your replication configuration, and all of them have a default value, so if you don't specify any variable it will work correctly but, it would be a good idea to chnage some of them, for instance your root password or replication user and password. To do that you can export specified below variables:

(For test environment it's not necessary to set any variables, it works with default values.)

```bash
# First DB container name.
export MYSQL_FIRST_DB_NAME='db-master'

# Second DB container name.
export MYSQL_SECOND_DB_NAME='db-slave'

# User on master container for repliation.
export MYSQL_FIRST_REPLICATION_USER='repl'

# Password for replica user on master container.
export MYSQL_FIRST_REPLICATION_PASSWORD='qazwsx'

# Root password for master DB.
export MYSQL_FIRST_ROOT_PASS='qazwsx'

# Root password for slave DB.
export MYSQL_SECOND_ROOT_PASS='qazwsx'

# Master container address (it depends on the container name "MYSQL_FIRST_DB_NAME" and should be same. You can specify IP addr instead "NOT RECOMMENDED").
export MYSQL_FIRST_HOST='db-master'

# Slave container address (it depends on the container name "MYSQL_SECOND_DB_NAME" and should be same. You can specify IP addr instead "NOT RECOMMENDED").
export MYSQL_SECOND_HOST='db-slave'

# Your docker bridge IP addr on host.
export DOCKER0_IP='172.17.0.1'

```

# Get started with master-master:

First of all You should set a variable to benefit from master-master replication "REPLICATION_METHOD=master-master".

```bash
export REPLICATION_METHOD=master-master
```

The default value of "REPLICATION_METHOD" is master-slave.

Like master-slave replication, several variables exist for master-master replication too. all of them have a default value, so if you don't specify any variable it will work correctly but, it would be a good idea to chnage some of them for instance, your root password or replication user and password. To do that you can export specified below variables:

(For test environment it's not necessary to set any variables, it works with default values.)

```bash
# First DB container name.
export MYSQL_FIRST_DB_NAME='db-master1'

# Second DB container name.
export MYSQL_SECOND_DB_NAME='db-master2'

# User on master1 container for repliation.
export MYSQL_FIRST_REPLICATION_USER='repl-master1'

# User on master2 container for repliation.
export MYSQL_SECOND_REPLICATION_USER='repl-master2'

# Password for replica user on master1 container.
export MYSQL_FIRST_REPLICATION_PASSWORD='qazwsx'

# Password for replica user on master2 container.
export MYSQL_SECOND_REPLICATION_PASSWORD='qazwsx'

# Root password for master1 DB.
export MYSQL_FIRST_ROOT_PASS='qazwsx'

# Root password for master2 DB.
export MYSQL_SECOND_ROOT_PASS='qazwsx'

# Master container address (it depends on the container name "MYSQL_FIRST_DB_NAME" and should be same. You can specify IP addr instead "NOT RECOMMENDED").
export MYSQL_FIRST_HOST='db-master1'

# Slave container address (it depends on the container name "MYSQL_SECOND_DB_NAME" and should be same. You can specify IP addr instead "NOT RECOMMENDED").
export MYSQL_SECOND_HOST='db-master2'

# Your docker bridge IP addr on host.
export DOCKER0_IP='172.17.0.1'

```
## Usage:

You can deploy your mysql replication by just executing these commands:

```bash
export REPLICATION_METHOD=master-master
or 
export REPLICATION_METHOD=master-slave

./mysql-deployment.sh
```

## Re-sync slave if down or crash:
```
# install pipeviewer first time
apt install pv

# backup single db
docker exec [container_id] mysqldump -uroot --password=[your_password] --triggers --routines --skip-lock-tables --single-transaction [db_name] | pv -W > [db_name] .sql
# import single db
pv [db_name].sql | docker exec -i [container_id] mysql -uroot --password=[your_password] [db_name]

# backup all dbs
docker exec [container_id] mysqldump -uroot --password=[your_password] --triggers --routines --skip-lock-tables --single-transaction --all-databases | pv -W > all_db.sql
# import all dbs
pv all_db.sql | docker exec -i [container_id] mysql -uroot --password=[your_password]
```

## Compose single instance
```
docker-compose -f docker-compose.single.yaml up -d --force-recreate
```

## Open URL PhpMyAdmin:
http://192.168.1.1:8000 (Your IP Address)

## How to contribute:
You are able to add other features related to this stack or expand it, it would be great to implement a replication for running instances.
Copyright 2021 Hosein Yousefi <yousefi.hosein.o@gmail.com>

