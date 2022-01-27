# mysql-backups
Try different type of mysql backups

Demo passwords for mysql users
```shell
MYSQL_ROOT_PASSWORD=111
MYSQL_PASSWORD=mydb_pwd
```

### Start database and check binary log
```shell
docker-compose up -d
docker exec -it mysql_db mysql -u mydb_user -p mydb -e "INSERT into my_tbl (my_field) VALUES ('val1');"
docker exec -it mysql_db ls -l /var/log/mysql/
```
```shell
-rw-r----- 1 mysql adm      9293 Dec 21 02:56 error.log
-rw-r----- 1 mysql mysql     177 Jan 27 20:41 mysql-bin.000001
-rw-r----- 1 mysql mysql 3085264 Jan 27 20:41 mysql-bin.000002
-rw-r----- 1 mysql mysql     426 Jan 27 20:42 mysql-bin.000003
-rw-r----- 1 mysql mysql      96 Jan 27 20:41 mysql-bin.index
```

### Full backup
```shell
docker exec -it mysql_db mysql -u mydb_user -p mysqldump -uroot -p --all-databases --single-transaction --flush-logs --master-data=2 > full_backup.sql
docker exec -it mysql_db ls -l /var/log/mysql/
```
Check that a new `mysql-bin.000004` file created and all new changes will be saved here
```shell
-rw-r----- 1 mysql adm      9293 Dec 21 02:56 error.log
-rw-r----- 1 mysql mysql     177 Jan 27 20:41 mysql-bin.000001
-rw-r----- 1 mysql mysql 3085264 Jan 27 20:41 mysql-bin.000002
-rw-r----- 1 mysql mysql     473 Jan 27 20:46 mysql-bin.000003
-rw-r----- 1 mysql mysql     154 Jan 27 20:46 mysql-bin.000004
-rw-r----- 1 mysql mysql     128 Jan 27 20:46 mysql-bin.index
```

Rollback looks like this:
```shell
drop database mydb;
create database mydb;
mysql -u root -p mydb < full_backup.sql
```

### Incremental backup
In order to take an incremental backup. You will need to flush the binary log again and save binary logs created from the last full backup.
```shell
docker exec -it mysql_db mysqladmin -uroot -p flush-logs
docker exec -it mysql_db ls -l /var/log/mysql/
```
Check that a new `mysql-bin.000005` file created
```shell
-rw-r----- 1 mysql adm      9293 Dec 21 02:56 error.log
-rw-r----- 1 mysql mysql     177 Jan 27 20:41 mysql-bin.000001
-rw-r----- 1 mysql mysql 3085264 Jan 27 20:41 mysql-bin.000002
-rw-r----- 1 mysql mysql     473 Jan 27 20:46 mysql-bin.000003
-rw-r----- 1 mysql mysql     201 Jan 27 20:48 mysql-bin.000004
-rw-r----- 1 mysql mysql     154 Jan 27 20:48 mysql-bin.000005
-rw-r----- 1 mysql mysql     160 Jan 27 20:48 mysql-bin.index
```

Rollback looks like this:
```shell
drop database mydb;
create database mydb;
mysql -u root -p mydb < full_backup.sql
mysqlbinlog /var/log/mysql/mysql-bin.000004 | mysql -uroot -p mydb
mysqlbinlog /var/log/mysql/mysql-bin.000005 | mysql -uroot -p mydb
```