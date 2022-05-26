 # Домашнее задание к занятию "6.3. MySQL"

## Задача 1
> Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.
> Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и восстановитесь из него.
> Перейдите в управляющую консоль `mysql` внутри контейнера.
> Используя команду `\h` получите список управляющих команд.
> Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.
> Подключитесь к восстановленной БД и получите список таблиц из этой БД.
> **Приведите в ответе** количество записей с `price` > 300.

### Ответ на задачу 1

- sudo apt update

- sudo apt install apt-transport-https ca-certificates curl software-properties-common

- curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

- sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

- sudo apt update

- apt-cache policy docker-ce

- sudo apt install docker-ce

- sudo systemctl status docker

```
$ sudo systemctl status docker
● docker.service - Docker Application Container Engine
     Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
     Active: active (running) since Thu 2022-05-26 14:58:49 UTC; 1min 42s ago
```

- ИЛИ одной строкой: vagrant@dev02:~$ sudo apt update && sudo apt install apt-transport-https ca-certificates curl software-properties-common &&  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" && sudo apt update &&  apt-cache policy docker-ce && sudo apt install docker-ce && sudo systemctl status docker

- но это какая-то совсем грустная история, в итоге набросал для vagrant сценарий:

```
Vagrant.configure("2") do |config|

  #config.vm.box = "bento/ubuntu-20.04" 
  config.vm.box = "ubuntu/bionic64"
  config.vm.hostname = "dev03"

  # require plugin https://github.com/leighmcculloch/vagrant-docker-compose
  config.vagrant.plugins = "vagrant-docker-compose"

  # install docker and docker-compose
  config.vm.provision :docker
  config.vm.provision :docker_compose

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
    vb.customize ["modifyvm", :id, "--memory", "2048"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
  end

end
```

- sudo docker pull mysql:8.0

```
vagrant@dev03:~$ sudo docker pull mysql:8.0
8.0: Pulling from library/mysql
c32ce6654453: Pull complete
415d08ee031a: Pull complete
7a38fec2542f: Pull complete
352881ee8fe9: Pull complete
b8e20da291b6: Pull complete
66c2a8cc1999: Pull complete
d3a3a8e49878: Pull complete
e33a48832bec: Pull complete
410b942b8b28: Pull complete
d5323c9dd265: Pull complete
e51041021063: Pull complete
b68b4cbc496e: Pull complete
Digest: sha256:dc3cdcf3025c3257e8047bb0eaee9d5a42d9f694f84fc5e7b6d12710ba7f6fcb
Status: Downloaded newer image for mysql:8.0
docker.io/library/mysql:8.0
```

- docker volume create mysql-conf
- docker volume create mysql-data

- docker run --rm --name mysqld -e MYSQL_ROOT_PASSWORD=mysql -ti -p 3306:3306 -v mysql-conf:/etc/mysql/ -v mysql-data:/var/lib/mysql/ mysql:8.0

- sudo docker ps

```
CONTAINER ID   IMAGE       COMMAND                  CREATED         STATUS         PORTS
NAMES
f346be73b769   mysql:8.0   "docker-entrypoint.s…"   4 minutes ago   Up 4 minutes   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 33060/tcp   mysqld
```

- sudo docker exec -it mysqld bash

- mysql -p mysql

```
mysql> \s
--------------
mysql  Ver 8.0.29 for Linux on x86_64 (MySQL Community Server - GPL)

Connection id:          11
Current database:       mysql
Current user:           root@localhost
SSL:                    Not in use
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         8.0.29 MySQL Community Server - GPL
Protocol version:       10
Connection:             Localhost via UNIX socket
Server characterset:    utf8mb4
Db     characterset:    utf8mb4
Client characterset:    latin1
Conn.  characterset:    latin1
UNIX socket:            /var/run/mysqld/mysqld.sock
Binary data as:         Hexadecimal
Uptime:                 6 min 13 sec

Threads: 2  Questions: 44  Slow queries: 0  Opens: 176  Flush tables: 3  Open tables: 95  Queries per second avg: 0.117
--------------
```

- список команд

```
mysql> \h

For information about MySQL products and services, visit:
   http://www.mysql.com/
For developer information, including the MySQL Reference Manual, visit:
   http://dev.mysql.com/
To buy MySQL Enterprise support, training, or other products, visit:
   https://shop.mysql.com/

List of all MySQL commands:
Note that all text commands must be first on line and end with ';'
?         (\?) Synonym for `help'.
clear     (\c) Clear the current input statement.
connect   (\r) Reconnect to the server. Optional arguments are db and host.
delimiter (\d) Set statement delimiter.
edit      (\e) Edit command with $EDITOR.
ego       (\G) Send command to mysql server, display result vertically.
exit      (\q) Exit mysql. Same as quit.
go        (\g) Send command to mysql server.
help      (\h) Display this help.
nopager   (\n) Disable pager, print to stdout.
notee     (\t) Don't write into outfile.
pager     (\P) Set PAGER [to_pager]. Print the query results via PAGER.
print     (\p) Print current command.
prompt    (\R) Change your mysql prompt.
quit      (\q) Quit mysql.
rehash    (\#) Rebuild completion hash.
source    (\.) Execute an SQL script file. Takes a file name as an argument.
status    (\s) Get status information from the server.
system    (\!) Execute a system shell command.
tee       (\T) Set outfile [to_outfile]. Append everything into given outfile.
use       (\u) Use another database. Takes database name as argument.
charset   (\C) Switch to another charset. Might be needed for processing binlog with multi-byte charsets.
warnings  (\W) Show warnings after every statement.
nowarning (\w) Don't show warnings after every statement.
resetconnection(\x) Clean session context.
query_attributes Sets string parameters (name1 value1 name2 value2 ...) for the next query to pick up.
ssl_session_data_print Serializes the current SSL session data to stdout or file

For server side help, type 'help contents'
```

- время пришло восстановить дамп, скачаем его с гитхаб и скопируем в mysql volumes
```
wget https://raw.githubusercontent.com/netology-code/virt-homeworks/virt-11/06-db-03-mysql/test_data/test_dump.sql
sudo cp test_dump.sql /var/lib/docker/volumes/mysql-conf/_data
```

- снова полезли в докер: sudo docker exec -it mysqld bash

- mysql> create database test_db;
``` Query OK, 1 row affected (0.02 sec) ```

- mysql -uroot -pmysql test_db < /etc/mysql/test_dump.sql

- mysql -pmysql

- подключимся и посмотрим, что вышло:

```
mysql>  use test_db;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql>  show tables;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.00 sec)

mysql> select count(*) from orders where price > 300;
+----------+
| count(*) |
+----------+
|        1 |
+----------+
1 row in set (0.00 sec)
```

## Задача 2

> Создайте пользователя test в БД c паролем test-pass, используя:
> - плагин авторизации mysql_native_password
> - срок истечения пароля - 180 дней 
> - количество попыток авторизации - 3 
> - максимальное количество запросов в час - 100
> - аттрибуты пользователя:
    > - Фамилия "Pretty"
    > - Имя "James"

> Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.
    
> Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и **приведите в ответе к задаче**.

### Ответ на задачу 2

- CREATE USER 'test'@'localhost' IDENTIFIED BY 'test-pass';

```
Query OK, 0 rows affected (0.01 sec)

mysql> select * from INFORMATION_SCHEMA.USER_ATTRIBUTES;
+------------------+-----------+-----------+
| USER             | HOST      | ATTRIBUTE |
+------------------+-----------+-----------+
| root             | %         | NULL      |
| mysql.infoschema | localhost | NULL      |
| mysql.session    | localhost | NULL      |
| mysql.sys        | localhost | NULL      |
| root             | localhost | NULL      |
| test             | localhost | NULL      |
+------------------+-----------+-----------+
6 rows in set (0.00 sec)
```

- изменим пользователя в соответствии с тз

```
mysql> ALTER USER 'test'@'localhost'
    -> IDENTIFIED BY 'test-pass'
    -> WITH
    -> MAX_QUERIES_PER_HOUR 100
    -> PASSWORD EXPIRE INTERVAL 180 DAY
    -> FAILED_LOGIN_ATTEMPTS 3 PASSWORD_LOCK_TIME UNBOUNDED
    -> ATTRIBUTE '{"fam": "Pretty", "name": "James"}';
Query OK, 0 rows affected (0.01 sec)
```

```
mysql> select * from INFORMATION_SCHEMA.USER_ATTRIBUTES;
+------------------+-----------+------------------------------------+
| USER             | HOST      | ATTRIBUTE                          |
+------------------+-----------+------------------------------------+
| root             | %         | NULL                               |
| mysql.infoschema | localhost | NULL                               |
| mysql.session    | localhost | NULL                               |
| mysql.sys        | localhost | NULL                               |
| root             | localhost | NULL                               |
| test             | localhost | {"fam": "Pretty", "name": "James"} |
+------------------+-----------+------------------------------------+
6 rows in set (0.00 sec)
```

- дадим пользователю право делать select

```
mysql> GRANT Select ON test_db.orders TO 'test'@'localhost';
Query OK, 0 rows affected, 1 warning (0.01 sec)
```

- данные по полюзователю test из INFORMATION_SCHEMA.USER_ATTRIBUTES

```
mysql> SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE USER='test';
+------+-----------+------------------------------------+
| USER | HOST      | ATTRIBUTE                          |
+------+-----------+------------------------------------+
| test | localhost | {"fam": "Pretty", "name": "James"} |
+------+-----------+------------------------------------+
1 row in set (0.00 sec)
```


## Задача 3
> Установите профилирование `SET profiling = 1`.
> Изучите вывод профилирования команд `SHOW PROFILES;`.
> Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.
> Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
> - на `MyISAM`
> - на `InnoDB`

### Ответ на задачу 3
> Установите профилирование `SET profiling = 1`.

```
mysql>  SET profiling = 1;
Query OK, 0 rows affected, 1 warning (0.00 sec)
```

> Изучите вывод профилирования команд `SHOW PROFILES;`.

```
mysql> SHOW PROFILES;
+----------+------------+--------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                              |
+----------+------------+--------------------------------------------------------------------+
|        1 | 0.00060525 | SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE USER='test' |
+----------+------------+--------------------------------------------------------------------+
1 row in set, 1 warning (0.00 sec)
```

> Исследуйте, какой `engine` используется в таблице БД `test_db`

- используется InnoDB

```
mysql> SELECT TABLE_NAME,ENGINE,ROW_FORMAT,TABLE_ROWS,DATA_LENGTH,INDEX_LENGTH FROM information_schema.TABLES WHERE table_name = 'orders'
and TABLE_SCHEMA = 'test_db' ORDER BY ENGINE asc;
+------------+--------+------------+------------+-------------+--------------+
| TABLE_NAME | ENGINE | ROW_FORMAT | TABLE_ROWS | DATA_LENGTH | INDEX_LENGTH |
+------------+--------+------------+------------+-------------+--------------+
| orders     | InnoDB | Dynamic    |          5 |       16384 |            0 |
+------------+--------+------------+------------+-------------+--------------+
1 row in set (0.00 sec)
```

> Измените `engine`

```
mysql>  ALTER TABLE orders ENGINE = MyISAM;
Query OK, 5 rows affected (0.11 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SELECT TABLE_NAME,ENGINE,ROW_FORMAT,TABLE_ROWS,DATA_LENGTH,INDEX_LENGTH FROM information_schema.TABLES WHERE table_name = 'orders' and  TABLE_SCHEMA = 'test_db' ORDER BY ENGINE asc;
+------------+--------+------------+------------+-------------+--------------+
| TABLE_NAME | ENGINE | ROW_FORMAT | TABLE_ROWS | DATA_LENGTH | INDEX_LENGTH |
+------------+--------+------------+------------+-------------+--------------+
| orders     | MyISAM | Dynamic    |          5 |       16384 |            0 |
+------------+--------+------------+------------+-------------+--------------+
1 row in set (0.00 sec)
```

```
mysql> ALTER TABLE orders ENGINE = InnoDB;
Query OK, 5 rows affected (0.25 sec)
Records: 5  Duplicates: 0  Warnings: 0
```

```
mysql> SELECT TABLE_NAME,ENGINE,ROW_FORMAT,TABLE_ROWS,DATA_LENGTH,INDEX_LENGTH FROM information_schema.TABLES WHERE table_name = 'orders'
and  TABLE_SCHEMA = 'test_db' ORDER BY ENGINE asc;
+------------+--------+------------+------------+-------------+--------------+
| TABLE_NAME | ENGINE | ROW_FORMAT | TABLE_ROWS | DATA_LENGTH | INDEX_LENGTH |
+------------+--------+------------+------------+-------------+--------------+
| orders     | InnoDB | Dynamic    |          5 |       16384 |            0 |
+------------+--------+------------+------------+-------------+--------------+
1 row in set (0.00 sec)
```

- посмотрим на профили
```
mysql> SHOW PROFILES;
+----------+------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query
                                                                     |
+----------+------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
|        1 | 0.00060525 | SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE USER='test'
                                                                     |
|        2 | 0.00419425 | SELECT TABLE_NAME,ENGINE,ROW_FORMAT,TABLE_ROWS,DATA_LENGTH,INDEX_LENGTH FROM information_schema.TABLES WHERE table_name = 'orders' and  TABLE_SCHEMA = 'test_db' ORDER BY ENGINE asc |
|        3 | 0.00093000 | SELECT TABLE_NAME,ENGINE,ROW_FORMAT,TABLE_ROWS,DATA_LENGTH,INDEX_LENGTH FROM information_schema.TABLES WHERE table_name = 'orders' and TABLE_SCHEMA = 'test_db' ORDER BY ENGINE asc  |
|        4 | 0.11387100 | ALTER TABLE orders ENGINE = MyISAM
                                                                     |
|        5 | 0.00086125 | SELECT TABLE_NAME,ENGINE,ROW_FORMAT,TABLE_ROWS,DATA_LENGTH,INDEX_LENGTH FROM information_schema.TABLES WHERE table_name = 'orders' and  TABLE_SCHEMA = 'test_db' ORDER BY ENGINE asc |
|        6 | 0.25018600 | ALTER TABLE orders ENGINE = InnoDB
                                                                     |
+----------+------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
6 rows in set, 1 warning (0.00 sec)
```

## Задача 4 

> Изучите файл `my.cnf` в директории /etc/mysql.
> Измените его согласно ТЗ (движок InnoDB):
> - Скорость IO важнее сохранности данных
> - Нужна компрессия таблиц для экономии места на диске
> - Размер буффера с незакомиченными транзакциями 1 Мб
> - Буффер кеширования 30% от ОЗУ
> - Размер файла логов операций 100 Мб

> Приведите в ответе измененный файл `my.cnf`.

### Ответ на задачу 4

> - Скорость IO важнее сохранности данных

innodb_flush_log_at_trx_commit = 0
* https://dev.mysql.com/doc/refman/5.7/en/innodb-parameters.html#sysvar_innodb_flush_log_at_trx_commit

> - Нужна компрессия таблиц для экономии места на диске

раньше использовалось такое, насколько помню - innodb_file_format = Barracuda, но теперь приводит к ошибке: "[Server] unknown variable 'innodb_file_format=Barracuda'", а все потому что "The following InnoDB file format configuration options were deprecated in MySQL 5.7.7 and are now removed". Сейсас по всей видимости - innodb_file_per_table
* https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html#sysvar_innodb_file_per_table

> - Размер буффера с незакомиченными транзакциями 1 Мб

innodb_log_buffer_size = 1M
* https://dev.mysql.com/doc/refman/5.7/en/innodb-parameters.html#sysvar_innodb_log_buffer_size

> - Буффер кеширования 30% от ОЗУ

innodb_buffer_pool_size = 600M
* https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html#sysvar_innodb_buffer_pool_size

> - Размер файла логов операций 100 Мб

max_binlog_size = 100M (вот здесь как бы вопрос, а не innodb_log_file_size? вроде был max_binlog_size)
* https://dev.mysql.com/doc/refman/8.0/en/replication-options-binary-log.html#sysvar_max_binlog_size


- cat /etc/mysql/my.cnf

```
## some skipped
#
# Custom config should go here
!includedir /etc/mysql/conf.d/

#> - Скорость IO важнее сохранности данных
innodb_flush_log_at_trx_commit = 0
#https://dev.mysql.com/doc/refman/5.7/en/innodb-parameters.html#sysvar_innodb_flush_log_at_trx_commit

#> - Нужна компрессия таблиц для экономии места на диске
innodb_file_per_table = ON
#https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html#sysvar_innodb_file_per_table

#> - Размер буффера с незакомиченными транзакциями 1 Мб
innodb_log_buffer_size = 1M
#https://dev.mysql.com/doc/refman/5.7/en/innodb-parameters.html#sysvar_innodb_log_buffer_size

#> - Буффер кеширования 30% от ОЗУ
innodb_buffer_pool_size = 600M
https://dev.mysql.com/doc/refman/5.7/en/innodb-parameters.html#sysvar_innodb_buffer_pool_size

#> - Размер файла логов операций 100 Мб
max_binlog_size = 100M
#https://dev.mysql.com/doc/refman/8.0/en/replication-options-binary-log.html#sysvar_max_binlog_size
```