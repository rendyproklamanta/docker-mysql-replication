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

### Steps
- Rename .env.example to .env
- Edit [.env](.env) file variable as yours
- Edit [mysql-deployment.sh](mysql-deployment.sh) with your custom configuration

# Get started with master-slave:

There are several variables which is your replication configuration, and all of them have a default value, so if you don't specify any variable it will work correctly but, it would be a good idea to chnage some of them, for instance your root password or replication user and password. To do that you can export specified below variables:


```bash
export REPLICATION_METHOD=master-slave
```


# Get started with master-master:

First of all You should set a variable to benefit from master-master replication "REPLICATION_METHOD=master-master".

```bash
export REPLICATION_METHOD=master-master
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
# install pipeviewer for first time only
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
http://192.168.1.1:8000 [your_ip_addres]:[port]
```
> Login Using Credential Root
user: root
pass: R1Wn11UBFlCX

> Login Using Credential Master
user: usr_master
pass: U18E36GEMNQGg

> Login Using Credential Slave
user: usr_read
pass: U2Fv93xF9GgcD
```

## How to contribute:
You are able to add other features related to this stack or expand it, it would be great to implement a replication for running instances.
Copyright 2021 Hosein Yousefi <yousefi.hosein.o@gmail.com>