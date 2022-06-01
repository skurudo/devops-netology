# Домашнее задание к занятию "6.5. Elasticsearch"

---

## Задача 1
> В этом задании вы потренируетесь в:
> - установке elasticsearch
> - первоначальном конфигурировании elastcisearch
> - запуске elasticsearch в docker
> Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
> [документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):
> - составьте Dockerfile-манифест для elasticsearch
> - соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
> - запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

> Требования к `elasticsearch.yml`:
> - данные `path` должны сохраняться в `/var/lib`
> - имя ноды должно быть `netology_test`

> В ответе приведите:
> - текст Dockerfile манифеста
> - ссылку на образ в репозитории dockerhub
> - ответ `elasticsearch` на запрос пути `/` в json виде

> Подсказки:
> - возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- > при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
> - при некоторых проблемах вам поможет docker директива ulimit
> - elasticsearch в логах обычно описывает проблему и пути ее решения
> Далее мы будем работать с данным экземпляром elasticsearch.

### Ответ на задачу 1

- снова используем vagrant с установленным докером из домашнего задания 6.3, сделаем отдельную машину

- docker pull centos:7

```
vagrant@dev05:~$ docker pull centos:7
7: Pulling from library/centos
2d473b07cdd5: Pull complete
Digest: sha256:c73f515d06b0fa07bb18d8202035e739a494ce760aa73129f60f4bf2bd22b407
Status: Downloaded newer image for centos:7
docker.io/library/centos:7
```

- готовим Dockerfile

```
FROM centos:7

EXPOSE 9200 9300

USER 0

RUN export ES_HOME="/var/lib/elasticsearch" && \
    yum -y install wget && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.0-linux-x86_64.tar.gz && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.0-linux-x86_64.tar.gz.sha512 && \
    sha512sum -c elasticsearch-7.17.0-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-7.17.0-linux-x86_64.tar.gz && \
    rm -f elasticsearch-7.17.0-linux-x86_64.tar.gz* && \
    mv elasticsearch-7.17.0 ${ES_HOME} && \
    useradd -m -u 1000 elasticsearch && \
    chown elasticsearch:elasticsearch -R ${ES_HOME} && \
    yum -y remove wget && \
    yum clean all

COPY --chown=elasticsearch:elasticsearch config/* /var/lib/elasticsearch/config/
    
	RUN mkdir /var/lib/elasticsearch/snapshots &&\
    chown elasticsearch:elasticsearch /var/lib/elasticsearch/snapshots
	RUN mkdir /var/lib/logs \
    && chown elasticsearch:elasticsearch /var/lib/logs \
    && mkdir /var/lib/data \
    && chown elasticsearch:elasticsearch /var/lib/data

USER 1000

ENV ES_HOME="/var/lib/elasticsearch" \
    ES_PATH_CONF="/var/lib/elasticsearch/config"
WORKDIR ${ES_HOME}

CMD ["sh", "-c", "${ES_HOME}/bin/elasticsearch"]
```

- готовим elasticsearch.yml (указываем интересующие нас позиции)

```
# Use a descriptive name for your cluster:
#
cluster.name: netology_test
discovery.type: single-node
# Path to directory where to store the data (separate multiple locations by comma):
#
path.data: /var/lib/data
#
# Path to log files:
#
path.logs: /var/lib/logs
#Settings REPOSITORY PATH
#
path.repo: /var/lib/elasticsearch/snapshots
# Set the bind address to a specific IP (IPv4 or IPv6):
#
network.host: 0.0.0.0
# Pass an initial list of hosts to perform discovery when this node is started:
# The default list of hosts is ["127.0.0.1", "[::1]"]
#
discovery.seed_hosts: ["127.0.0.1", "[::1]"]
```

- docker build -t elasticsearchcustom:v00 /home/vagrant/ -- ошибка, нет доступа к артифактам

```
--2022-06-01 03:31:44--  https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.0-linux-x86_64.tar.gz
Resolving artifacts.elastic.co (artifacts.elastic.co)... 34.120.127.130, 2600:1901:0:1d7::
Connecting to artifacts.elastic.co (artifacts.elastic.co)|34.120.127.130|:443... connected.
HTTP request sent, awaiting response... 403 Forbidden
2022-06-01 03:31:45 ERROR 403: Forbidden.
```

- выясняем, что есть проблемы с доступом, гоним трафик к 34.120.127.130 ( https://artifacts.elastic.co) через впн 

- запускаем повторным билд: docker build -t elasticsearchcustom:v00 /home/vagrant/ 

```
последние строки

Removing intermediate container 5ca589134794
 ---> 2583b3f09cca
Step 9/9 : CMD ["sh", "-c", "${ES_HOME}/bin/elasticsearch"]
 ---> Running in 890a2639c103
Removing intermediate container 890a2639c103
 ---> c5cbe23fc2ed
Successfully built c5cbe23fc2ed
Successfully tagged elasticsearchcustom:v00
```

- docker build . -t skurudo/elasticsearchcustom

- docker login -u "skurudo" -p "password" docker.io

- docker push skurudo/elasticsearchcustom

```
vagrant@dev05:~$ docker push skurudo/elasticsearchcustom
Using default tag: latest
The push refers to repository [docker.io/skurudo/elasticsearchcustom]
20459190932f: Pushed
759c970313aa: Pushed
174f56854903: Pushed
latest: digest: sha256:eeda588f6e6a4f33cf42c0e50edbd62d7a1bbf3e7dd04ace98b98737171c7a8f size: 950
```

- ссылка: https://hub.docker.com/r/skurudo/elasticsearchcustom/tags

- sudo docker run --rm --name elastic -p 9200:9200 -p 9300:9300 skurudo/elasticsearchcustom

- docker ps

```
vagrant@dev05:~$ docker ps
CONTAINER ID   IMAGE                             COMMAND                  CREATED              STATUS              PORTS                                                                                  NAMES
3b3d7ee51272   skurudo/elasticsearchcustom:v03   "sh -c ${ES_HOME}/bi…"   About a minute ago   Up About a minute   0.0.0.0:9200->9200/tcp, :::9200->9200/tcp, 0.0.0.0:9300->9300/tcp, :::9300->9300/tcp   elastic
```

- c первого раза не взлетело, но несколько редакций - обточили пути и все поехало

- curl -X GET 'localhost:9200/'

```
vagrant@dev05:~$ curl -X GET 'localhost:9200/'
{
  "name" : "3b3d7ee51272",
  "cluster_name" : "netology_test",
  "cluster_uuid" : "PWBWINL5QMqPMz72w_0-EA",
  "version" : {
    "number" : "7.17.0",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "bee86328705acaa9a6daede7140defd4d9ec56bd",
    "build_date" : "2022-01-28T08:36:04.875279988Z",
    "build_snapshot" : false,
    "lucene_version" : "8.11.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

## Задача 2

> В этом задании вы научитесь:
> - создавать и удалять индексы
> - изучать состояние кластера
> - обосновывать причину деградации доступности данных

> Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
> и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

> | Имя | Количество реплик | Количество шард |
> |-----|-------------------|-----------------|
> | ind-1| 0 | 1 |
> | ind-2 | 1 | 2 |
> | ind-3 | 2 | 4 |

> Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.
> Получите состояние кластера `elasticsearch`, используя API.
> Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?
> Удалите все индексы.

> **Важно**
> При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
> иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

### Ответ на задачу 2

- cоздание индексов
```
vagrant@dev05:~$ curl -X PUT localhost:9200/ind-1 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 1,  "number_of_replicas": 0 }}'
vagrant@dev05:~$ curl -X PUT localhost:9200/ind-2 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 2,  "number_of_replicas": 1 }}'
vagrant@dev05:~$ curl -X PUT localhost:9200/ind-3 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 4,  "number_of_replicas": 2 }}'
```

- cписок индексов
```
vagrant@dev05:~$ curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases gFKsaSiQSGyMrZtfLk8yxg   1   0         40            0     38.1mb         38.1mb
green  open   ind-1            ut-H7UP8SoOH2oowaHV57w   1   0          0            0       226b           226b
yellow open   ind-3            qMsYavywRSKBIXa0UWohPw   4   2          0            0       904b           904b
yellow open   ind-2            Sd_7yhidQm2SM7WScK_1OA   2   1          0            0       452b           452b
```

- cтатус индексов
```
vagrant@dev05:~$ curl -X GET 'http://localhost:9200/_cluster/health/ind-1?pretty'
{
  "cluster_name" : "netology_test",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 1,
  "active_shards" : 1,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
vagrant@dev05:~$ curl -X GET 'http://localhost:9200/_cluster/health/ind-2?pretty'
{
  "cluster_name" : "netology_test",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 2,
  "active_shards" : 2,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 2,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.0
}
vagrant@dev05:~$ curl -X GET 'http://localhost:9200/_cluster/health/ind-3?pretty'
{
  "cluster_name" : "netology_test",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 4,
  "active_shards" : 4,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 8,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.0
}
```

- cтатус кластера
```
vagrant@dev05:~$ curl -XGET localhost:9200/_cluster/health/?pretty=true
{
  "cluster_name" : "netology_test",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 10,
  "active_shards" : 10,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.0
}
```

- удаление индексов

```
vagrant@dev05:~$ curl -X DELETE 'http://localhost:9200/ind-1?pretty'
{
  "acknowledged" : true
}
vagrant@dev05:~$ curl -X DELETE 'http://localhost:9200/ind-2?pretty'
{
  "acknowledged" : true
}
vagrant@dev05:~$ curl -X DELETE 'http://localhost:9200/ind-3?pretty'
{
  "acknowledged" : true
}
vagrant@dev05:~$  curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases gFKsaSiQSGyMrZtfLk8yxg   1   0         40            0     38.1mb         38.1mb
```

По поводу удаления индексов, нашел еще команду для удаления всех индексов сразу:
```
curl -X DELETE 'http://localhost:9200/_all'
```

- индексы в статусе yellow по той причине, что у них указано число реплик, а у нас нет никаких других серверов и реплицироваться нам по сути некуда... при одном сервере видимо ничего страшного

## Задача 3
> В данном задании вы научитесь:
> - создавать бэкапы данных
> - восстанавливать индексы из бэкапов
> Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

> Используя API [зарегистрируйте]> (https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
> данную директорию как `snapshot repository` c именем `netology_backup`.

**> Приведите в ответе** запрос API и результат вызова API для создания репозитория.

> Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

> [Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
> состояния кластера `elasticsearch`.

> **Приведите в ответе** список файлов в директории со `snapshot`ами.

> Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

> [Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
> кластера `elasticsearch` из `snapshot`, созданного ранее. 
> **Приведите в ответе** запрос к API восстановления и итоговый список индексов.

> Подсказки:
> - возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

### Ответ на задачу 3

- получаем рыбой по морде
```
Error 451 Unavailable For Legal Reasons
Unavailable For Legal Reasons

Error 54113
Details: cache-ams21078-AMS 1654070544 4176471155
```

- утираемся и добавляем адреса через vpn

```
sku@Angurva:~$ host cloud.elastic.co
cloud.elastic.co is an alias for s.ssl.global.fastly.net.
s.ssl.global.fastly.net has address 151.101.1.94
s.ssl.global.fastly.net has address 151.101.65.94
s.ssl.global.fastly.net has address 151.101.129.94
s.ssl.global.fastly.net has address 151.101.193.94
```

- провели регистрацию, сделали триал
```
Username
	elastic
Password
	XzHUuf1GyFscyxSjab6swI65
```

- docker exec -u root -it elastic bash

```
[root@3b3d7ee51272 elasticsearch]# mkdir $ES_HOME/snapshots
mkdir: cannot create directory '/var/lib/elasticsearch/snapshots': File exists
```

```
[root@3b3d7ee51272 elasticsearch]# ls -la /var/lib/elasticsearch/
total 672
drwxr-xr-x  1 elasticsearch elasticsearch   4096 Jun  1 07:43 .
drwxr-xr-x  1 root          root            4096 Jun  1 07:44 ..
-rw-r--r--  1 elasticsearch elasticsearch   3860 Jan 28 08:34 LICENSE.txt
-rw-r--r--  1 elasticsearch elasticsearch 627787 Jan 28 08:38 NOTICE.txt
-rw-r--r--  1 elasticsearch elasticsearch   2710 Jan 28 08:34 README.asciidoc
drwxr-xr-x  2 elasticsearch elasticsearch   4096 Jan 28 08:41 bin
drwxr-xr-x  1 elasticsearch elasticsearch   4096 Jun  1 07:45 config
drwxr-xr-x  9 elasticsearch elasticsearch   4096 Jan 28 08:41 jdk
drwxr-xr-x  3 elasticsearch elasticsearch   4096 Jan 28 08:41 lib
drwxr-xr-x  1 elasticsearch elasticsearch   4096 Jun  1 08:12 logs
drwxr-xr-x 61 elasticsearch elasticsearch   4096 Jan 28 08:41 modules
drwxr-xr-x  2 elasticsearch elasticsearch   4096 Jan 28 08:38 plugins
drwxr-xr-x  2 elasticsearch elasticsearch   4096 Jun  1 07:43 snapshots
```


- curl -XPOST localhost:9200/_snapshot/netology_backup?pretty -H 'Content-Type: application/json' -d'{"type": "fs", "settings": { "location":"/var/lib/elasticsearch/snapshots" }}'

```
[root@3b3d7ee51272 elasticsearch]# curl -XPOST localhost:9200/_snapshot/netology_backup?pretty -H 'Content-Type: application/json' -d'{"type": "fs", "settings": { "location":"/var/lib/elasticsearch/snapshots" }}'
{
  "acknowledged" : true
}
```

-  curl -X GET http://localhost:9200/_snapshot/netology_backup?pretty

```
[root@3b3d7ee51272 elasticsearch]# curl -X GET http://localhost:9200/_snapshot/netology_backup?pretty
{
  "netology_backup" : {
    "type" : "fs",
    "settings" : {
      "location" : "/var/lib/elasticsearch/snapshots"
    }
  }
}
```

- curl -X PUT localhost:9200/test -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 1,  "number_of_replicas": 0 }}'

```
{"acknowledged":true,"shards_acknowledged":true,"index":"test"}
```

- curl -X GET http://localhost:9200/test?pretty

```
[root@3b3d7ee51272 elasticsearch]# curl -X GET http://localhost:9200/test?pretty
{
  "test" : {
    "aliases" : { },
    "mappings" : { },
    "settings" : {
      "index" : {
        "routing" : {
          "allocation" : {
            "include" : {
              "_tier_preference" : "data_content"
            }
          }
        },
        "number_of_shards" : "1",
        "provided_name" : "test",
        "creation_date" : "1654071559106",
        "number_of_replicas" : "0",
        "uuid" : "5Rd_CW6CRhqwGzmWON6Xxg",
        "version" : {
          "created" : "7170099"
        }
      }
    }
  }
}
```

- curl -X PUT localhost:9200/_snapshot/netology_backup/elasticsearch?wait_for_completion=true

```
[root@3b3d7ee51272 elasticsearch]# curl -X PUT localhost:9200/_snapshot/netology_backup/elasticsearch?wait_for_completion=true
{"snapshot":{"snapshot":"elasticsearch","uuid":"30m8X635Rq-Cy4fC83oSNw","repository":"netology_backup","version_id":7170099,"version":"7.17.0","indices":[".geoip_databases",".ds-.logs-deprecation.elasticsearch-default-2022.06.01-000001","test",".ds-ilm-history-5-2022.06.01-000001"],"data_streams":["ilm-history-5",".logs-deprecation.elasticsearch-default"],"include_global_state":true,"state":"SUCCESS","start_time":"2022-06-01T08:20:59.885Z","start_time_in_millis":1654071659885,"end_time":"2022-06-01T08:21:01.487Z","end_time_in_millis":1654071661487,"duration_in_millis":1602,"failures":[],"shards":{"total":4,"failed":0,"successful":4},"feature_states":[{"feature_name":"geoip","indices":[".geoip_databases"]}]}}[root@3b3d7ee51272
```

```
[root@3b3d7ee51272 elasticsearch]# ls -la /var/lib/elasticsearch/snapshots/
total 60
drwxr-xr-x 1 elasticsearch elasticsearch  4096 Jun  1 08:21 .
drwxr-xr-x 1 elasticsearch elasticsearch  4096 Jun  1 07:43 ..
-rw-r--r-- 1 elasticsearch elasticsearch  1425 Jun  1 08:21 index-0
-rw-r--r-- 1 elasticsearch elasticsearch     8 Jun  1 08:21 index.latest
drwxr-xr-x 6 elasticsearch elasticsearch  4096 Jun  1 08:21 indices
-rw-r--r-- 1 elasticsearch elasticsearch 29319 Jun  1 08:21 meta-30m8X635Rq-Cy4fC83oSNw.dat
-rw-r--r-- 1 elasticsearch elasticsearch   712 Jun  1 08:21 snap-30m8X635Rq-Cy4fC83oSNw.dat
```

- удаление индекса test и добавление test-2

```[root@3b3d7ee51272 elasticsearch]# curl -X DELETE "localhost:9200/test?pretty"
{
  "acknowledged" : true
}

[root@3b3d7ee51272 elasticsearch]#  curl -X PUT localhost:9200/test-2?pretty -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 1,  "number_of_replicas": 0 }}'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test-2"
}

```

- восстановление и проверка

И сразу же столкнулись с ошибкой
```
[root@3b3d7ee51272 elasticsearch]# curl -X POST localhost:9200/_snapshot/netology_backup/elasticsearch/_restore?pretty -H 'Content-Type: application/json' -d'{"include_global_state":true}'
{
  "error" : {
    "root_cause" : [
      {
        "type" : "snapshot_restore_exception",
        "reason" : "[netology_backup:elasticsearch/30m8X635Rq-Cy4fC83oSNw] cannot restore index [.ds-.logs-deprecation.elasticsearch-default-2022.06.01-000001] because an open index with same name already exists in the cluster. Either close or delete the existing index or restore the index under a different name by providing a rename pattern and replacement name"
      }
    ],
    "type" : "snapshot_restore_exception",
    "reason" : "[netology_backup:elasticsearch/30m8X635Rq-Cy4fC83oSNw] cannot restore index [.ds-.logs-deprecation.elasticsearch-default-2022.06.01-000001] because an open index with same name already exists in the cluster. Either close or delete the existing index or restore the index under a different name by providing a rename pattern and replacement name"
  },
  "status" : 500
}
```

Удалим все индексы

```[root@3b3d7ee51272 elasticsearch]# curl -X DELETE "localhost:9200/_all?pretty"
{
  "acknowledged" : true
}
```

Все удалилось, но что-то осталось

```
[root@3b3d7ee51272 elasticsearch]# curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases gFKsaSiQSGyMrZtfLk8yxg   1   0         40            0     38.1mb         38.1mb
```

Выключаем это странное:
```
[root@3b3d7ee51272 elasticsearch]# curl -X PUT "localhost:9200/_cluster/settings?pretty" -H 'Content-Type: application/json' -d' { "persistent" : { "ingest.geoip.downloader.enabled": false } } '
{
  "acknowledged" : true,
  "persistent" : {
    "ingest" : {
      "geoip" : {
        "downloader" : {
          "enabled" : "false"
        }
      }
    }
  },
  "transient" : { }
}
```

Проверяем, что индексов не осталось:
```
[root@3b3d7ee51272 elasticsearch]# curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index uuid pri rep docs.count docs.deleted store.size pri.store.size
```

Однако все равно восстановление завершается с ошибкой:

```
curl -X POST localhost:9200/_snapshot/netology_backup/elasticsearch/_restore?pretty -H 'Content-Type: application/json' -d'{"include_global_state":true}'

[root@3250b4e20b9e elasticsearch]# curl -X POST localhost:9200/_snapshot/netology_backup/elasticsearch/_restore?pretty -H 'Content-Type: application/json' -d'{"include_global_state":true}'
{
  "error" : {
    "root_cause" : [
      {
        "type" : "snapshot_restore_exception",
        "reason" : "[netology_backup:elasticsearch/TBBjiyTzRy2kAXBQmCuFow] cannot restore index [.ds-ilm-history-5-2022.06.01-000001] because an open index with same name already exists in the cluster. Either close or delete the existing index or restore the index under a different name by providing a rename pattern and replacement name"
      }
    ],
    "type" : "snapshot_restore_exception",
    "reason" : "[netology_backup:elasticsearch/TBBjiyTzRy2kAXBQmCuFow] cannot restore index [.ds-ilm-history-5-2022.06.01-000001] because an open index with same name already exists in the cluster. Either close or delete the existing index or restore the index under a different name by providing a rename pattern and replacement name"
  },
  "status" : 500
}
```

Сам снапшот есть, дополнительные снимаются

```
 curl -X GET "http://localhost:9200/_snapshot/netology_backup/*"
 
 [root@3250b4e20b9e elasticsearch]# curl -XGET "http://localhost:9200/_snapshot/netology_backup/*"
{"snapshots":[{"snapshot":"elasticsearch","uuid":"TBBjiyTzRy2kAXBQmCuFow","repository":"netology_backup","version_id":7170099,"version":"7.17.0","indices":["test",".geoip_databases",".ds-ilm-history-5-2022.06.01-000001",".ds-.logs-deprecation.elasticsearch-default-2022.06.01-000001"],"data_streams":["ilm-history-5",".logs-deprecation.elasticsearch-default"],"include_global_state":true,"state":"SUCCESS","start_time":"2022-06-01T08:46:51.201Z","start_time_in_millis":1654073211201,"end_time":"2022-06-01T08:46:52.817Z","end_time_in_millis":1654073212817,"duration_in_millis":1616,"failures":[],"shards":{"total":4,"failed":0,"successful":4},"feature_states":[{"feature_name":"geoip","indices":[".geoip_databases"]}]}],"total":1,"remaining":0}
```

 curl -X POST localhost:9200/_snapshot/netology_backup/elasticsearch2/_restore?wait_for_completion=true