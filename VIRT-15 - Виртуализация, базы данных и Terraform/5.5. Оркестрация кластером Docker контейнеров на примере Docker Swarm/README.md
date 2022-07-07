# Домашнее задание к занятию "5.5. Оркестрация кластером Docker контейнеров на примере Docker Swarm"

## Задача 1

Дайте письменые ответы на следующие вопросы:

- В чём отличие режимов работы сервисов в Docker Swarm кластере: replication и global?
- Какой алгоритм выбора лидера используется в Docker Swarm кластере?
- Что такое Overlay Network?

### Ответ на задачу 1

``` - В чём отличие режимов работы сервисов в Docker Swarm кластере: replication и global? ```

 В режиме global приложение или приложения запускае(ю)тся на всех нодах, а в режиме replication указывается количество реплик используемых для приложения(т.е. на какой-то ноде может не быть экземпляров приложений). 
 
``` - Какой алгоритм выбора лидера используется в Docker Swarm кластере? ```

Raft

```
- Протокол решает проблему согласованности - чтобы все manager-ноды имели одинаковое представление о состоянии кластера
- Для отказоустойчивой работы должно быть не менее трёх manager-нод.
- Количество нод обязательно должно быть нечётным, но лучше не более 7 (рекомендация из документации Docker).
- Среди manager-нод выбирается лидер, его задача гарантировать согласованность.
- Лидер отправляет keepalive-пакеты с заданной периодичностью в пределах 150-300мс. 
Если пакеты не пришли, менеджеры начинают выборы нового лидера.
- Если кластер разбит, нечётное количество нод должно гарантировать, что кластер останется консистентным, 
т.к. факт изменения состояния считается совершенным, если его отразило большинство нод. Если разбить кластер пополам,
нечётное число гарантирует, что в какой-то части кластера будеть большинство нод.
```

![Raft: выбор нового лидера](https://habrastorage.org/r/w1560/files/584/dcc/4e8/584dcc4e857d4e0a999e487d2e0dbbbe.gif)

``` - Что такое Overlay Network? ```

Оверлейная сеть (от англ. Overlay Network) — общий случай логической сети, создаваемой поверх другой сети. Узлы оверлейной сети могут быть связаны либо физическим соединением, либо логическим, для которого в основной сети существуют один или несколько соответствующих маршрутов из физических соединений.

В нашем случае речь идет об L2 VPN сети для связи docker демонов между собой.


## Задача 2

Создать ваш первый Docker Swarm кластер в Яндекс.Облаке
Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
```
docker node ls
```

### Ответ на задачу 2

Делаем правки centos-7-base.json

```
folder_id и token
```

после проверки packer запускает build

```
$ packer build centos-7-base.json
```

Успешненько:

```
Build 'yandex' finished after 4 minutes 41 seconds.
==> Wait completed after 4 minutes 41 seconds
==> Builds finished. The artifacts of successful builds are:
--> yandex: A disk image was created: centos-7-base (id: fd85b24m06e37c8l0p21) with family name centos
```


Обновляем токен (наш протух):

```
yc iam service-account --folder-id b1gqpnr6ba58jcqk0264 list
yc iam key create --folder-name default --service-account-name default-sa --output key.json
yc config set service-account-key key.json
yc iam create-token
```

Идем в terraform - init

```
vagrant@dev-docker:~/05-virt-05-docker-swarm/src/terraform$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/null...
- Finding latest version of hashicorp/local...
- Finding latest version of yandex-cloud/yandex...
- Installing hashicorp/null v3.1.1...
- Installed hashicorp/null v3.1.1 (unauthenticated)
- Installing hashicorp/local v2.2.3...
- Installed hashicorp/local v2.2.3 (unauthenticated)
- Installing yandex-cloud/yandex v0.76.0...
- Installed yandex-cloud/yandex v0.76.0 (unauthenticated)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.
Terraform has been successfully initialized!
```

Далее...

```vagrant@dev-docker:~/05-virt-05-docker-swarm/src/terraform$ terraform plan```

И поехали...

```vagrant@dev-docker:~/05-virt-05-docker-swarm/src/terraform$ terraform apply```

Сделалось:

```
Apply complete! Resources: 13 added, 0 changed, 0 destroyed.
Outputs:
external_ip_address_node01 = "51.250.88.199"
external_ip_address_node02 = "51.250.65.189"
external_ip_address_node03 = "51.250.82.3"
external_ip_address_node04 = "51.250.67.13"
external_ip_address_node05 = "51.250.81.183"
external_ip_address_node06 = "51.250.84.97"
internal_ip_address_node01 = "192.168.101.11"
internal_ip_address_node02 = "192.168.101.12"
internal_ip_address_node03 = "192.168.101.13"
internal_ip_address_node04 = "192.168.101.14"
internal_ip_address_node05 = "192.168.101.15"
internal_ip_address_node06 = "192.168.101.16"
```

Выполнилось:

```
vagrant@dev-docker:~/05-virt-05-docker-swarm/src/terraform$ ssh centos@51.250.88.199
[centos@node01 ~]$ docker node ls
Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.24/nodes": dial unix /var/run/docker.sock: connect: permission denied
[centos@node01 ~]$ sudo docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
xyr7u8f0mvr24ycpztingw69v *   node01.netology.yc   Ready     Active         Leader           20.10.17
s1jdgobweci1qfvf1sb6guuk5     node02.netology.yc   Ready     Active         Reachable        20.10.17
scti70shglq5agx2jz0te56bm     node03.netology.yc   Ready     Active         Reachable        20.10.17
3oak4md76d7kk4go2gd6bteol     node04.netology.yc   Ready     Active                          20.10.17
k4mtwguvox9q2rbnayw4zmstn     node05.netology.yc   Ready     Active                          20.10.17
vbky9sire60g69njdw8vk8uyp     node06.netology.yc   Ready     Active                          20.10.17
```

![делается](https://github.com/skurudo/devops-netology/blob/main/VIRT-15%20-%20%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F%2C%20%D0%B1%D0%B0%D0%B7%D1%8B%20%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D1%85%20%D0%B8%20Terraform/5.5.%20%D0%9E%D1%80%D0%BA%D0%B5%D1%81%D1%82%D1%80%D0%B0%D1%86%D0%B8%D1%8F%20%D0%BA%D0%BB%D0%B0%D1%81%D1%82%D0%B5%D1%80%D0%BE%D0%BC%20Docker%20%D0%BA%D0%BE%D0%BD%D1%82%D0%B5%D0%B9%D0%BD%D0%B5%D1%80%D0%BE%D0%B2%20%D0%BD%D0%B0%20%D0%BF%D1%80%D0%B8%D0%BC%D0%B5%D1%80%D0%B5%20Docker%20Swarm/01-01.jpg)

![сделалося](https://github.com/skurudo/devops-netology/blob/main/VIRT-15%20-%20%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F%2C%20%D0%B1%D0%B0%D0%B7%D1%8B%20%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D1%85%20%D0%B8%20Terraform/5.5.%20%D0%9E%D1%80%D0%BA%D0%B5%D1%81%D1%82%D1%80%D0%B0%D1%86%D0%B8%D1%8F%20%D0%BA%D0%BB%D0%B0%D1%81%D1%82%D0%B5%D1%80%D0%BE%D0%BC%20Docker%20%D0%BA%D0%BE%D0%BD%D1%82%D0%B5%D0%B9%D0%BD%D0%B5%D1%80%D0%BE%D0%B2%20%D0%BD%D0%B0%20%D0%BF%D1%80%D0%B8%D0%BC%D0%B5%D1%80%D0%B5%20Docker%20Swarm/01-02.jpg)


## Задача 3

Создать ваш первый, готовый к боевой эксплуатации кластер мониторинга, состоящий из стека микросервисов.
Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
```
docker service ls
```
### Ответ на задачу 3

```
[centos@node01 ~]$ sudo docker service ls
ID             NAME                                MODE         REPLICAS   IMAGE                                          PORTS
ehi0x82eo4ka   swarm_monitoring_alertmanager       replicated   1/1        stefanprodan/swarmprom-alertmanager:v0.14.0
9w9fcdu2s9yb   swarm_monitoring_caddy              replicated   1/1        stefanprodan/caddy:latest                      *:3000->3000/tcp, *:9090->9090/tcp, *:9093-9094->9093-9094/tcp
6v4dlnq073ws   swarm_monitoring_cadvisor           global       6/6        google/cadvisor:latest
ii7k8f4ey5k1   swarm_monitoring_dockerd-exporter   global       6/6        stefanprodan/caddy:latest
99a2gn97cuvo   swarm_monitoring_grafana            replicated   1/1        stefanprodan/swarmprom-grafana:5.3.4
e062str4ba5y   swarm_monitoring_node-exporter      global       6/6        stefanprodan/swarmprom-node-exporter:v0.16.0
ldz13pt14v8v   swarm_monitoring_prometheus         replicated   1/1        stefanprodan/swarmprom-prometheus:v2.5.0
evkx7jg6xfy0   swarm_monitoring_unsee              replicated   1/1        cloudflare/unsee:v0.8.0
```


![делается](https://github.com/skurudo/devops-netology/blob/main/VIRT-15%20-%20%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F%2C%20%D0%B1%D0%B0%D0%B7%D1%8B%20%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D1%85%20%D0%B8%20Terraform/5.5.%20%D0%9E%D1%80%D0%BA%D0%B5%D1%81%D1%82%D1%80%D0%B0%D1%86%D0%B8%D1%8F%20%D0%BA%D0%BB%D0%B0%D1%81%D1%82%D0%B5%D1%80%D0%BE%D0%BC%20Docker%20%D0%BA%D0%BE%D0%BD%D1%82%D0%B5%D0%B9%D0%BD%D0%B5%D1%80%D0%BE%D0%B2%20%D0%BD%D0%B0%20%D0%BF%D1%80%D0%B8%D0%BC%D0%B5%D1%80%D0%B5%20Docker%20Swarm/02-01.jpg)

![сделалося](https://github.com/skurudo/devops-netology/blob/main/VIRT-15%20-%20%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F%2C%20%D0%B1%D0%B0%D0%B7%D1%8B%20%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D1%85%20%D0%B8%20Terraform/5.5.%20%D0%9E%D1%80%D0%BA%D0%B5%D1%81%D1%82%D1%80%D0%B0%D1%86%D0%B8%D1%8F%20%D0%BA%D0%BB%D0%B0%D1%81%D1%82%D0%B5%D1%80%D0%BE%D0%BC%20Docker%20%D0%BA%D0%BE%D0%BD%D1%82%D0%B5%D0%B9%D0%BD%D0%B5%D1%80%D0%BE%D0%B2%20%D0%BD%D0%B0%20%D0%BF%D1%80%D0%B8%D0%BC%D0%B5%D1%80%D0%B5%20Docker%20Swarm/02-02.jpg)

![сделалося](0https://github.com/skurudo/devops-netology/blob/main/VIRT-15%20-%20%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F%2C%20%D0%B1%D0%B0%D0%B7%D1%8B%20%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D1%85%20%D0%B8%20Terraform/5.5.%20%D0%9E%D1%80%D0%BA%D0%B5%D1%81%D1%82%D1%80%D0%B0%D1%86%D0%B8%D1%8F%20%D0%BA%D0%BB%D0%B0%D1%81%D1%82%D0%B5%D1%80%D0%BE%D0%BC%20Docker%20%D0%BA%D0%BE%D0%BD%D1%82%D0%B5%D0%B9%D0%BD%D0%B5%D1%80%D0%BE%D0%B2%20%D0%BD%D0%B0%20%D0%BF%D1%80%D0%B8%D0%BC%D0%B5%D1%80%D0%B5%20Docker%20Swarm/02-03.jpg)

## Задача 4 (*)

Выполнить на лидере Docker Swarm кластера команду (указанную ниже) и дать письменное описание её функционала, что она делает и зачем она нужна:
```
см.документацию: https://docs.docker.com/engine/swarm/swarm_manager_locking/
docker swarm update --autolock=true
```

### Ответ на задачу 4

--autolock=true обязывает вводить ключ разблокировки на ноде, чтобы она могла заново присоединиться к кластеру, если была перезапущена. Нужно для защиты доступа к нодам, чтобы нельзя было получить доступ без ключа.

```
[centos@node01 ~]$ sudo docker swarm update --autolock=false
Swarm updated.
```

```
vagrant@dev-docker:~/05-virt-05-docker-swarm/src/terraform$ ssh centos@51.250.82.3
[centos@node03 ~]$ sudo docker swarm update --autolock=true
Swarm updated.
To unlock a swarm manager after it restarts, run the `docker swarm unlock`
command and provide the following key:

    SWMKEY-1-uhsdzKY6FnxrOQ9PcZhiwBg/UajORtaBadYri6djg0g

Please remember to store this key in a password manager, since without it you
will not be able to restart the manager.
[centos@node03 ~]$ sudo docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
xyr7u8f0mvr24ycpztingw69v     node01.netology.yc   Ready     Active         Leader           20.10.17
s1jdgobweci1qfvf1sb6guuk5     node02.netology.yc   Ready     Active         Reachable        20.10.17
scti70shglq5agx2jz0te56bm *   node03.netology.yc   Ready     Active         Reachable        20.10.17
3oak4md76d7kk4go2gd6bteol     node04.netology.yc   Ready     Active                          20.10.17
k4mtwguvox9q2rbnayw4zmstn     node05.netology.yc   Ready     Active                          20.10.17
vbky9sire60g69njdw8vk8uyp     node06.netology.yc   Ready     Active                          20.10.17
```

```
[centos@node03 ~]$ sudo docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
xyr7u8f0mvr24ycpztingw69v     node01.netology.yc   Down      Active         Unreachable      20.10.17
s1jdgobweci1qfvf1sb6guuk5     node02.netology.yc   Ready     Active         Leader           20.10.17
scti70shglq5agx2jz0te56bm *   node03.netology.yc   Ready     Active         Reachable        20.10.17
3oak4md76d7kk4go2gd6bteol     node04.netology.yc   Ready     Active                          20.10.17
k4mtwguvox9q2rbnayw4zmstn     node05.netology.yc   Ready     Active                          20.10.17
vbky9sire60g69njdw8vk8uyp     node06.netology.yc   Ready     Active                          20.10.17
```

```
[centos@node01 ~]$ sudo docker swarm unlock
```

Лидер поменялся:

```
[centos@node01 ~]$ sudo docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
xyr7u8f0mvr24ycpztingw69v *   node01.netology.yc   Ready     Active         Reachable        20.10.17
s1jdgobweci1qfvf1sb6guuk5     node02.netology.yc   Ready     Active         Leader           20.10.17
scti70shglq5agx2jz0te56bm     node03.netology.yc   Ready     Active         Reachable        20.10.17
3oak4md76d7kk4go2gd6bteol     node04.netology.yc   Ready     Active                          20.10.17
k4mtwguvox9q2rbnayw4zmstn     node05.netology.yc   Ready     Active                          20.10.17
vbky9sire60g69njdw8vk8uyp     node06.netology.yc   Ready     Active                          20.10.17
```

---

### Finale

И не забываем сделать:

```
vagrant@dev-docker:~/05-virt-05-docker-swarm/src/terraform$ terraform destroy

Destroy complete! Resources: 12 destroyed.
```

И удалить диск с образом, а также проверить оставшиеся услуги.