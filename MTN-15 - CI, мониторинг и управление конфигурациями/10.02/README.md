# Домашнее задание к занятию "10.02. Системы мониторинга"

## Обязательные задания

1. Опишите основные плюсы и минусы pull и push систем мониторинга.

**Push**

Плюсы:
* Возможность направлять данные в несколько таргетов
* Работает за NAT
* Мониторинг ноды без лишних алёртов, при нестабильном или непостоянном доступе в сеть, например
* Можно получить данные с хостов, с которых мы их изначально не ждали. Иными словам, при вводе ноды в эксплуатацию, нужно настроить только ноду, сервер настраивать не нужно

Минусы:
* Агенты могут зафлудить сервера запросами и устроить ему DDoS
* Требует открытия порта сервера наружу периметра, что может создать проблемы со службой безопасности и безопасности в принципе
* Могут приходить данные, которые нам не нужны, т.е. сервер не контролирует ничего: частоту отправки данных, объём и тд.

**Pull**

Плюсы
* Не требует открытия порта сервера наружу периметра
* Подойдёт в ситуации, когда с ноды могут запрашивать данные разные сервисы, каждому из которых нужны свои данные
* Сервер тянет данные с агентов когда может, и если сейчас нет свободных ресурсов - заберёт данные позже
* Сервер сам определяет, в каком объёме нужны данные
Проще защитить трафик, т.к. часто используется HTTP/S

Минусы:
* Не работает за NAT, нужно что-то придумывать
* Менее производительный, более ресурсоёмкий, т.к. данные забираются по HTTP/S в основном

2. Какие из ниже перечисленных систем относятся к push модели, а какие к pull? А может есть гибридные?

    - **Prometheus** - Pull (Push с Pushgateway)
    - **TICK** - Push
    - **Zabbix** - Push (Pull с Zabbix Proxy)
    - **VictoriaMetrics** - Push/Pull, в зависимости от источника
    - **Nagios** - Pull

3. Склонируйте себе [репозиторий](https://github.com/influxdata/sandbox/tree/master) и запустите TICK-стэк, 
используя технологии docker и docker-compose.(по инструкции ./sandbox up )

```
vagrant@dev-ansible:~$ git clone https://github.com/influxdata/sandbox.git
Cloning into 'sandbox'...
remote: Enumerating objects: 1718, done.
remote: Counting objects: 100% (32/32), done.
remote: Compressing objects: 100% (22/22), done.
remote: Total 1718 (delta 13), reused 25 (delta 10), pack-reused 1686
Receiving objects: 100% (1718/1718), 7.17 MiB | 2.48 MiB/s, done.
Resolving deltas: 100% (946/946), done.

vagrant@dev-ansible:~/sandbox$ sudo ./sandbox up

можем получить ошибку: 
xdg-open: command not found

vagrant@dev-ansible:~$ sudo apt-get install xdg-utils --fix-missing

vagrant@dev-ansible:~/sandbox$ sudo ./sandbox up
```

```
vagrant@dev-ansible:~/sandbox$ sudo docker ps
CONTAINER ID   IMAGE                   COMMAND                  CREATED         STATUS         PORTS
                                                                                       NAMES
b6a10261469d   chrono_config           "/entrypoint.sh chro…"   6 minutes ago   Up 6 minutes   0.0.0.0:8888->8888/tcp, :::8888->8888/tcp                                                                                         sandbox_chronograf_1
d4dd1ad1bdae   kapacitor               "/entrypoint.sh kapa…"   6 minutes ago   Up 6 minutes   0.0.0.0:9092->9092/tcp, :::9092->9092/tcp                                                                                         sandbox_kapacitor_1
cd307f4a798c   telegraf                "/entrypoint.sh tele…"   6 minutes ago   Up 6 minutes   8092/udp, 8125/udp, 8094/tcp
                                                                                       sandbox_telegraf_1
ddbca0d18b2d   sandbox_documentation   "/documentation/docu…"   6 minutes ago   Up 6 minutes   0.0.0.0:3010->3000/tcp, :::3010->3000/tcp
                                                                                       sandbox_documentation_1
474ed7b898c8   influxdb                "/entrypoint.sh infl…"   6 minutes ago   Up 6 minutes   0.0.0.0:8082->8082/tcp, :::8082->8082/tcp, 0.0.0.0:8086->8086/tcp, :::8086->8086/tcp, 0.0.0.0:8089->8089/udp, :::8089->8089/udp   sandbox_influxdb_1
```

В виде решения на это упражнение приведите выводы команд с вашего компьютера (виртуальной машины):

```    
    - curl http://localhost:8086/ping

vagrant@dev-ansible:~/sandbox$
```        
    - curl http://localhost:8888

vagrant@dev-ansible:~/sandbox$ curl http://localhost:8888
<!DOCTYPE html><html><head><link rel="stylesheet" href="/index.c708214f.css"><meta http-equiv="Content-type" content="text/html; charset=utf-8"><title>Chronograf</title><link rel="icon shortcut" href="/favicon.70d63073.ico"></head><body> <div id="react-root" data-basepath=""></div> <script type="module" src="/index.e81b88ee.js"></script><script src="/index.a6955a67.js" nomodule="" defer></script> </body></html>
```    

```    
    - curl http://localhost:9092/kapacitor/v1/ping

vagrant@dev-ansible:~/sandbox$
```

А также скриншот веб-интерфейса ПО chronograf (`http://localhost:8888`). 
P.S.: если при запуске некоторые контейнеры будут падать с ошибкой - проставьте им режим `Z`, например
`./data:/var/lib:Z`

![](https://github.com/skurudo/devops-netology/blob/main/MTN-15%20-%20CI%2C%20%D0%BC%D0%BE%D0%BD%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D0%BD%D0%B3%20%D0%B8%20%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5%20%D0%BA%D0%BE%D0%BD%D1%84%D0%B8%D0%B3%D1%83%D1%80%D0%B0%D1%86%D0%B8%D1%8F%D0%BC%D0%B8/10.02/001.jpg)


1. Изучите список [telegraf inputs](https://github.com/influxdata/telegraf/tree/master/plugins/inputs).
    - Добавьте в конфигурацию telegraf плагин - [disk](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/disk):
    ```
    [[inputs.disk]]
      ignore_fs = ["tmpfs", "devtmpfs", "devfs", "iso9660", "overlay", "aufs", "squashfs"]
    ```
    - Так же добавьте в конфигурацию telegraf плагин - [mem](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/mem):
    ```
    [[inputs.mem]]
    ```
    - После настройки перезапустите telegraf.
 
    - Перейдите в веб-интерфейс Chronograf (`http://localhost:8888`) и откройте вкладку `Data explorer`.
    - Нажмите на кнопку `Add a query`
    - Изучите вывод интерфейса и выберите БД `telegraf.autogen`
    - В `measurments` выберите mem->host->telegraf_container_id , а в `fields` выберите used_percent. 
    Внизу появится график утилизации оперативной памяти в контейнере telegraf.
    - Вверху вы можете увидеть запрос, аналогичный SQL-синтаксису. 
    Поэкспериментируйте с запросом, попробуйте изменить группировку и интервал наблюдений.
    - Приведите скриншот с отображением
    метрик утилизации места на диске (disk->host->telegraf_container_id) из веб-интерфейса.  


![](https://github.com/skurudo/devops-netology/blob/main/MTN-15%20-%20CI%2C%20%D0%BC%D0%BE%D0%BD%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D0%BD%D0%B3%20%D0%B8%20%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5%20%D0%BA%D0%BE%D0%BD%D1%84%D0%B8%D0%B3%D1%83%D1%80%D0%B0%D1%86%D0%B8%D1%8F%D0%BC%D0%B8/10.02/002.jpg)


2. Добавьте в конфигурацию telegraf следующий плагин - [docker](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/docker):
```
[[inputs.docker]]
  endpoint = "unix:///var/run/docker.sock"
```

Дополнительно вам может потребоваться донастройка контейнера telegraf в `docker-compose.yml` дополнительного volume и 
режима privileged:
```
  telegraf:
    image: telegraf:1.4.0
    privileged: true
    volumes:
      - ./etc/telegraf.conf:/etc/telegraf/telegraf.conf:Z
      - /var/run/docker.sock:/var/run/docker.sock:Z
    links:
      - influxdb
    ports:
      - "8092:8092/udp"
      - "8094:8094"
      - "8125:8125/udp"
```

После настройки перезапустите telegraf, обновите веб интерфейс и приведите скриншотом список `measurments` в 
веб-интерфейсе базы telegraf.autogen . Там должны появиться метрики, связанные с docker.

![](https://github.com/skurudo/devops-netology/blob/main/MTN-15%20-%20CI%2C%20%D0%BC%D0%BE%D0%BD%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D0%BD%D0%B3%20%D0%B8%20%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5%20%D0%BA%D0%BE%D0%BD%D1%84%D0%B8%D0%B3%D1%83%D1%80%D0%B0%D1%86%D0%B8%D1%8F%D0%BC%D0%B8/10.02/003.jpg)

![](https://github.com/skurudo/devops-netology/blob/main/MTN-15%20-%20CI%2C%20%D0%BC%D0%BE%D0%BD%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D0%BD%D0%B3%20%D0%B8%20%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5%20%D0%BA%D0%BE%D0%BD%D1%84%D0%B8%D0%B3%D1%83%D1%80%D0%B0%D1%86%D0%B8%D1%8F%D0%BC%D0%B8/10.02/004.jpg)
