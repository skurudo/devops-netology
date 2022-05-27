# Домашнее задание к занятию "6.4. PostgreSQL"

---

## Задача 1
> Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.
> Подключитесь к БД PostgreSQL используя `psql`.
> Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.
> **Найдите и приведите** управляющие команды для:
> - вывода списка БД
> - подключения к БД
> - вывода списка таблиц
> - вывода описания содержимого таблиц
> - выхода из psql

### Ответ на задачу 1
- снова используем vagrant с установленным докером из домашнего задания 6.3, сделаем отдельную машину

- sudo docker pull postgres:13

```
vagrant@dev04:~$ sudo docker pull postgres:13
13: Pulling from library/postgres
214ca5fb9032: Pull complete
e6930973d723: Pull complete
aea7c534f4e1: Pull complete
d0ab8814f736: Pull complete
648cc138980a: Pull complete
7804b894301c: Pull complete
cfce56252c3f: Pull complete
8cce7305e3b6: Pull complete
aa0c0227e86a: Pull complete
8246cee774af: Pull complete
8a72a860cc25: Pull complete
d30d1a75aee3: Pull complete
7dd91cedb27f: Pull complete
Digest: sha256:e3354da5b11f8c52eca6ae00725acf5bb0d07c17d33ceea95d706188e14a0dd5
Status: Downloaded newer image for postgres:13
docker.io/library/postgres:13
```
- sudo docker images

```
vagrant@dev04:~$ docker images
REPOSITORY   TAG       IMAGE ID       CREATED      SIZE
postgres     13        03349ea4cfbc   9 days ago   373MB
```

- sudo docker volume create data
- sudo docker volume create etc

- sudo docker run --rm --name pg -e POSTGRES_PASSWORD=postgres -ti -p 5432:5432 -v data:/var/lib/postgresql -v etc:/etc postgres:13

- sudo docker exec -it pg bash

- psql -U postgres

- \?

```
postgres=# \?
General
  \copyright             show PostgreSQL usage and distribution terms
  \crosstabview [COLUMNS] execute query and display results in crosstab
  \errverbose            show most recent error message at maximum verbosity
  \g [(OPTIONS)] [FILE]  execute query (and send results to file or |pipe);
                         \g with no arguments is equivalent to a semicolon
  \gdesc                 describe result of query, without executing it
  \gexec                 execute query, then execute each value in its result
  \gset [PREFIX]         execute query and store results in psql variables
  \gx [(OPTIONS)] [FILE] as \g, but forces expanded output mode
  \q                     quit psql
  \watch [SEC]           execute query every SEC seconds

скип-скип-скип, ибо много там
--More--
```
> - вывода списка БД

команда - \l или расширенный вывод \l+
```
 \l
 
 
                                  List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(3 rows)
```

> - подключения к БД

команда - \c
```
 \c postgres
 
 You are now connected to database "postgres" as user "postgres".
```

> - вывода списка таблиц

команда - \dtS
```
postgres=# \dtS
                    List of relations
   Schema   |          Name           | Type  |  Owner
------------+-------------------------+-------+----------
 pg_catalog | pg_aggregate            | table | postgres
 pg_catalog | pg_am                   | table | postgres
 pg_catalog | pg_amop                 | table | postgres
 pg_catalog | pg_amproc               | table | postgres
 pg_catalog | pg_attrdef              | table | postgres
 pg_catalog | pg_attribute            | table | postgres
 pg_catalog | pg_auth_members         | table | postgres
 pg_catalog | pg_authid               | table | postgres
 pg_catalog | pg_cast                 | table | postgres
 pg_catalog | pg_class                | table | postgres
 pg_catalog | pg_collation            | table | postgres
```

> - вывода описания содержимого таблиц

команда - \dS+ имя таблицы
```
postgres=# \dS+ pg_class
                                         Table "pg_catalog.pg_class"
       Column        |     Type     | Collation | Nullable | Default | Storage  | Stats target | Description
---------------------+--------------+-----------+----------+---------+----------+--------------+-------------
 oid                 | oid          |           | not null |         | plain    |              |
 relname             | name         |           | not null |         | plain    |              |
 relnamespace        | oid          |           | not null |         | plain    |              |
 reltype             | oid          |           | not null |         | plain    |              |
 reloftype           | oid          |           | not null |         | plain    |              |
 relowner            | oid          |           | not null |         | plain    |              |
 relam               | oid          |           | not null |         | plain    |              |
 relfilenode         | oid          |           | not null |         | plain    |              |
 reltablespace       | oid          |           | not null |         | plain    |              |
 relpages            | integer      |           | not null |         | plain    |              |
 reltuples           | real         |           | not null |         | plain    |              |
 relallvisible       | integer      |           | not null |         | plain    |              |
 reltoastrelid       | oid          |           | not null |         | plain    |              |
 relhasindex         | boolean      |           | not null |         | plain    |              |
 relisshared         | boolean      |           | not null |         | plain    |              |
 relpersistence      | "char"       |           | not null |         | plain    |              |
 relkind             | "char"       |           | not null |         | plain    |              |
 relnatts            | smallint     |           | not null |         | plain    |              |
 relchecks           | smallint     |           | not null |         | plain    |              |
 relhasrules         | boolean      |           | not null |         | plain    |              |
 relhastriggers      | boolean      |           | not null |         | plain    |              |
 relhassubclass      | boolean      |           | not null |         | plain    |              |
 relrowsecurity      | boolean      |           | not null |         | plain    |              |
 relforcerowsecurity | boolean      |           | not null |         | plain    |              |
 relispopulated      | boolean      |           | not null |         | plain    |              |
 relreplident        | "char"       |           | not null |         | plain    |              |
 relispartition      | boolean      |           | not null |         | plain    |              |
 relrewrite          | oid          |           | not null |         | plain    |              |
 relfrozenxid        | xid          |           | not null |         | plain    |              |
 relminmxid          | xid          |           | not null |         | plain    |              |
 relacl              | aclitem[]    |           |          |         | extended |              |
 reloptions          | text[]       | C         |          |         | extended |              |
 relpartbound        | pg_node_tree | C         |          |         | extended |              |
Indexes:
    "pg_class_oid_index" UNIQUE, btree (oid)
    "pg_class_relname_nsp_index" UNIQUE, btree (relname, relnamespace)
    "pg_class_tblspc_relfilenode_index" btree (reltablespace, relfilenode)
Access method: heap
```

> - выхода из psql

команда - \q

## Задача 2
> Используя `psql` создайте БД `test_database`.
> Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).
> Восстановите бэкап БД в `test_database`.
> Перейдите в управляющую консоль `psql` внутри контейнера.
> Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.
> Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` с наибольшим средним значением размера элементов в байтах.
> **Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

### Ответ на задачу 2
SELECT avg_width FROM pg_stats WHERE tablename='orders';
```
avg_width
-----------
         4
        16
         4
```

### Ход решения задачи 2
- sudo docker exec -it pg bash

- psql -U postgres

- CREATE DATABASE test_database;
```
postgres=# CREATE DATABASE test_database;
CREATE DATABASE
```
- выйдем ненадолго и скачаем дамп

- wget https://raw.githubusercontent.com/netology-code/virt-homeworks/master/06-db-04-postgresql/test_data/test_dump.sql

- cp test_dump.sql  /var/lib/docker/volumes/etc/_data/

- и назад - sudo docker exec -it pg bash

- psql -U postgres -f /etc/test_dump.sql

- вернемся обратно - psql -U postgres
 
 - подключимся к таблице - \c test_database
 
 - ANALYZE VERBOSE public.orders;
 ```
 test_database=# ANALYZE VERBOSE public.orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE
 ```

- SELECT avg_width FROM pg_stats WHERE tablename='orders';
```
test_database=# SELECT avg_width FROM pg_stats WHERE tablename='orders';
 avg_width
-----------
         4
        16
         4
(3 rows)
```

## Задача 3
> Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
> поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
> провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).
> Предложите SQL-транзакцию для проведения данной операции.
> Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

### Ответ на задачу 3
Например, можно сделать следующим образом:
```
CREATE TABLE orders_over_499_price (CHECK (price > 499)) INHERITS (orders);
CREATE TABLE
INSERT INTO orders_over_499_price SELECT * FROM orders WHERE price > 499;
INSERT 0 3
CREATE TABLE orders_below_499_price (CHECK (price <= 499)) INHERITS (orders);
CREATE TABLE
INSERT INTO orders_below_499_price SELECT * FROM orders WHERE price <= 499;
INSERT 0 5

test_database=# \dt
                 List of relations
 Schema |          Name          | Type  |  Owner
--------+------------------------+-------+----------
 public | orders                 | table | postgres
 public | orders_below_499_price | table | postgres
 public | orders_over_499_price  | table | postgres
(3 rows)
```

Изначально заложить разбиение базы можно, для этого может быть использовано два подхода - секционирование (Partitioning),  [материал](https://postgrespro.ru/docs/postgresql/10/ddl-partitioning#:~:text=PostgreSQL%20%D0%BF%D1%80%D0%B5%D0%B4%D0%BE%D1%81%D1%82%D0%B0%D0%B2%D0%BB%D1%8F%D0%B5%D1%82%20%D0%B2%D0%BE%D0%B7%D0%BC%D0%BE%D0%B6%D0%BD%D0%BE%D1%81%D1%82%D1%8C%20%D1%83%D0%BA%D0%B0%D0%B7%D0%B0%D1%82%D1%8C%2C%20%D0%BA%D0%B0%D0%BA,%D0%BA%D0%BE%D1%82%D0%BE%D1%80%D1%8B%D0%B5%20%D0%B1%D1%83%D0%B4%D1%83%D1%82%20%D1%81%D0%BE%D1%81%D1%82%D0%B0%D0%B2%D0%BB%D1%8F%D1%82%D1%8C%20%D0%BA%D0%BB%D1%8E%D1%87%20%D1%80%D0%B0%D0%B7%D0%B1%D0%B8%D0%B5%D0%BD%D0%B8%D1%8F))

А также матерые дядьки предлагают всякие интересные плагины по разбиению - [материал по разбиению](https://habr.com/ru/company/oleg-bunin/blog/309330/)

## Задача 4
> Используя утилиту `pg_dump` создайте бекап БД `test_database`.
> Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

### Ответ на задачу 4

- дамп - pg_dump -U postgres -d test_database > /etc/test_database_dump.sql
```
pg_dump -U postgres -d test_database > /etc/test_database_dump.sql

root@872f1c70b626:/# ls -la /etc/test_database_dump.sql
-rw-r--r-- 1 root root 2082 May 27 13:35 /etc/test_database_dump.sql
```

- добавить критерий UNIQUE

```
CREATE TABLE public.orders (
    id integer,
    title character varying(80) UNIQUE,
    price integer
);
```

( материал по UNIQUE - https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-unique-constraint/ )