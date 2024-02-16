# MySQL-replication-docker
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

### What is ProxySQL

ProxySQL is an open-source high-performance database proxy. It acts as an intermediary between database clients and database servers, providing various features to improve the performance, scalability, and manageability of database systems.

### Stacks:
- Mysql 8+
- Docker
- ProxySQL

### Steps
- Edit [mysql.env](mysql.env) file variable as yours
- Edit [mysql-deployment.sh](mysql-deployment.sh) with your custom configuration

- Init docker swarm
```
docker swarm init
```

- Add port firewall
```
ufw allow 3306
ufw allow 3307
ufw allow 6033
```

- Create network
```
docker network create --driver overlay mysql-network
```

- create dir
```
mkdir -p /var/lib/mysql
```

- goto dir and clone
```
cd /var/lib/mysql
git clone https://github.com/rendyproklamanta/docker-mysql-replication.git .
```

- Change enviroment variable like passwords
```
nano mysql.env
```

- Change deployment method (master-master / master-slave):
```
nano start.sh
```

- Set permission if using linux
```
chmod +x start.sh
```
- Run script
```
./start.sh
```

- Set auto start and re-sync on reboot :
```
> Enable startup service :
mv mysql-stack.service /etc/systemd/system/mysql-stack.service
sudo systemctl enable mysql-stack.service

> Check status after reboot :
sudo journalctl -u mysql-stack.service
```

## Re-sync slave if down or crash:
- install pipeviewer for first time only
```
apt install pv
```
### Single database
- backup single db
```
docker exec [container_id] mysqldump -uroot --password=[your_password] --triggers --routines --skip-lock-tables --single-transaction [db_name] | pv -W > [db_name] .sql
```
- import single db
```
pv [db_name].sql | docker exec -i [container_id] mysql -uroot --password=[your_password] [db_name]
```

### All databases
- backup all dbs
```
docker exec [container_id] mysqldump -uroot --password=[your_password] --triggers --routines --skip-lock-tables --single-transaction --all-databases | pv -W > all_db.sql
```
- import all dbs
```
pv all_db.sql | docker exec -i [container_id] mysql -uroot --password=[your_password]
```

## Running mysql with single instance
```
docker-compose -f docker-compose.single.yaml up -d --force-recreate
```

## Access :
- Login Using Credential Root in PMA
```
Link : http://localhost:8000 or http://[YOUR_IP_ADDRESS]:[PORT]
user : root
pass : R1Wn11UBFlCX
```

- Login Using Credential for Super User Proxysql 
> Recomended this cred to connect to your app or using mysql-client like navicat for load balance connection
```
host : localhost or [YOUR_IP_ADDRESS]
user : super_usr
pass : QdlZtA75V8jj
port : 6033
```

## How to contribute:
You are able to add other features related to this stack or expand it, it would be great to implement a replication for running instances.
Copyright 2021 Hosein Yousefi <yousefi.hosein.o@gmail.com>
