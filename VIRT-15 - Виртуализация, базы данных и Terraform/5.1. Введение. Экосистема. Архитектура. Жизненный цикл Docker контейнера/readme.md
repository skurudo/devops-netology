# Домашнее задание к занятию "5.3. Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера"

---

## Задача 1
> Сценарий выполения задачи:
> - создайте свой репозиторий на https://hub.docker.com;
> - выберете любой образ, который содержит веб-сервер Nginx;
> - создайте свой fork образа;
> - реализуйте функциональность:
> запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:
> ```
> <html>
> <head>
> Hey, Netology
> </head>
> <body>
> <h1>I’m DevOps Engineer!</h1>
> </body>
> </html>
> ```
> Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo.

### Ответ на задачу 1
https://hub.docker.com/r/skurudo/customngix/

Ход решения задачи
* докер установлен

* проверим запущен ли
```
 $ service docker status
● docker.service - Docker Application Container Engine
     Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2022-03-25 11:49:35 MSK; 1 months 0 days ago
TriggeredBy: ● docker.socket
       Docs: https://docs.docker.com
   Main PID: 998714 (dockerd)
      Tasks: 11
     Memory: 60.6M
     CGroup: /system.slice/docker.service
             └─998714 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
```

* ищем образ ->  
``` docker search nginx ```

* скачиваем nginx -> 
``` docker pull ubuntu/nginx ```

```
$  docker images
REPOSITORY   TAG       IMAGE ID       CREATED      SIZE
nginx          latest    fa5269854a5e   5 days ago   142MB
ubuntu/nginx   latest    33345394c4b7   6 days ago   144MB
```

* запускаем-проверяем -> 
```docker run -d -p 8181:80 ubuntu/nginx:latest ```

* ``` lynx localhost:8181 ```

```
    Welcome to nginx!

   If you see this page, the nginx web server is successfully installed and working. Further configuration is required.

   For online documentation and support please refer to nginx.org.
   Commercial support is available at nginx.com.

   Thank you for using nginx.
```

* сделали dockerfile
```
# base image
FROM ubuntu/nginx
# install basic apps
RUN apt-get clean && apt-get update
RUN apt-get install -qy nano
```

* собираем своё
```docker build -t customngix:v02 docker/```

* запускаем своё
```docker run -it -d customngix:v02 bash```

* ищем своё для входа
```docker ps```

* входим, чтобы сделать изменения
```docker exec -it d5ce495f0b9d bash```

* редактируем файл и выходим
```nano /var/www/html/index.nginx-debian.html && exit```

* закачиваем в хаб
```docker commit d5ce495f0b9d skurudo/customngix:v03```

* проверяем, все ли получилось
```lynx localhost:9191```

* ну вроде оно самое
```
Hey, Netology

I'm DevOps Engineer!
```

* и в хаб
``` docker push skurudo/customngix:v03 ```


PS: Подозреваю, что задачу решить проще, используя COPY в /var/www/html/ внутрь контейнера специально подготовленный индексный файл, но было интересно попробовать commit метод.


## Задача 2

> Посмотрите на сценарий ниже и ответьте на вопрос:
> "Подходит ли в этом сценарии использование Docker контейнеров или лучше подойдет виртуальная машина, физическая машина? Может быть возможны разные варианты?"
> Детально опишите и обоснуйте свой выбор.

> Сценарий:
> - Высоконагруженное монолитное java веб-приложение;
> - Nodejs веб-приложение;
> - Мобильное приложение c версиями для Android и iOS;
> - Шина данных на базе Apache Kafka;
> - Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;
> - Мониторинг-стек на базе Prometheus и Grafana;
> - MongoDB, как основное хранилище данных для java-приложения;
> - Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.


### Ответ на задачу 2
> - Высоконагруженное монолитное java веб-приложение;

Склоняюсь к виртуальной машине или физической машине, так как монолит разбить сложновато, а прямой доступ к ресурсах для высоконагруженного приложения будет лучше. Плюс есть неизвестное - не ясно, как масштабирование происходит и есть ли оно, по умолчанию не знаем, потому вариант виртуалки или физики.

> - Nodejs веб-приложение;

Да, вполне можно использовать докер - быстро развернется с нужными библиотеками и будет готово к работе

> - Мобильное приложение c версиями для Android и iOS;

Наверное нет для продакшена. Возможно подойдет для автотестов и эмуляторов, но в целом не уверен, что докер тут будет полезен. Более уместно использовать виртуальную машину.

> - Шина данных на базе Apache Kafka;

Скорее всего подойдет.

> - Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;

Подойдет докер, насколько читал и используется активно.

> - Мониторинг-стек на базе Prometheus и Grafana;

Докер подойдет для этой задачи.

> - MongoDB, как основное хранилище данных для java-приложения;

Вполне можно использовать докер, есть готовый образ.

> - Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.

Вопрос интересный.. в идеальном мире наверное лучше использовать виртуальную машину. Но на практике тот же gitlab вполне поднимают в докере.


## Задача 3

- Запустите первый контейнер из образа ***centos*** c любым тэгом в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```;
- Добавьте еще один файл в папку ```/data``` на хостовой машине;
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.

### Ответ на задачу 3

* берем образы для выполнения задания
```
$ docker search centos
$ docker pull centos
$ docker search debian
$ docker pull debian
```

* создаем общую папку
```
mkdir ~/docker/data
```

* запускаем контейнеры с общей папкой
```
$ docker run --name=centosd -d -v /root/docker/data:/data -t centos:latest  
$ docker run --name=debiand -d -v /root/docker/data:/data -t debian:latest 
```

* проверяем, что у нас запущены контейнеры
```$ docker ps
CONTAINER ID   IMAGE           COMMAND       CREATED          STATUS          PORTS     NAMES
dda83b12ca2b   debian:latest   "/bin/bash"   3 seconds ago    Up 1 second               debiand
42d8c61ba716   centos:latest   "/bin/bash"   39 seconds ago   Up 36 seconds             centosd
```

* заходим в контейнер и делаем файл
```
docker exec -it centosd /bin/bash
echo erer > /data/centos-01.txt
exit
```

* делаем файл на хост машине 
```
dsfdsf > /root/docker/data/host-file.txt
```

* заходим во второй контейнер
```
docker exec -it debiand /bin/bash
```

* проверяем листинг и содержимое
```
root@d255e2feb1b3:/# ls /data
centos-01.txt  host-file.txt
```

```
root@d255e2feb1b3:/# cat /data/centos-01.txt && cat /data/host-file.txt
erer
dsfdsf
```

## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

Соберите Docker образ с Ansible, загрузите на Docker Hub и пришлите ссылку вместе с остальными ответами к задачам.

### Ответ на задачу 4

* берем образ
```
$ docker pull ubuntu
```

* готовим dockerfile
```
FROM ubuntu:latest

RUN apt-get update && \
        apt install software-properties-common --assume-yes && \
        add-apt-repository --yes --update ppa:ansible/ansible && \
        apt install ansible --assume-yes

RUN mkdir /ansible && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts

WORKDIR /ansible

CMD [ "ansible-playbook", "--version" ]
```

* делаем билд 
```$ docker build -t ansiblecustom:v00 docker/```

* концовка вывода
```
Step 3/5 : RUN mkdir /ansible &&     mkdir -p /etc/ansible &&     echo 'localhost' > /etc/ansible/hosts
 ---> Running in 70676870fb57
Removing intermediate container 70676870fb57
 ---> 3d0ae4b012c7
Step 4/5 : WORKDIR /ansible
 ---> Running in 9587bda81ae7
Removing intermediate container 9587bda81ae7
 ---> 8ec727b9103c
Step 5/5 : CMD [ "ansible-playbook", "--version" ]
 ---> Running in 6fc96e3908c7
Removing intermediate container 6fc96e3908c7
 ---> f3bf9ccd3c23
Successfully built f3bf9ccd3c23
Successfully tagged ansiblecustom:v00
```

* логинимся
```$ docker login```

* добавляем тэг
```docker tag f3bf9ccd3c23 skurudo/ansiblecustom:v01```

* добавляем в докер хам
```docker push skurudo/ansiblecustom:v01```

* получилось :-)
https://hub.docker.com/r/skurudo/ansiblecustom