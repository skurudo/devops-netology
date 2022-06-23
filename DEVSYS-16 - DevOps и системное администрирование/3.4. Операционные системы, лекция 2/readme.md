# 3.4. Операционные системы, лекция 2

## 1. На лекции мы познакомились с node_exporter. В демонстрации его исполняемый файл запускался в background. Этого достаточно для демо, но не для настоящей production-системы, где процессы должны находиться под внешним управлением. Используя знания из лекции по systemd, создайте самостоятельно простой unit-файл для node_exporter:

сначала установим:
$ sudo apt install prometheus-node-exporter

* поместите его в автозагрузку,
$ sudo useradd node_exporter -s /sbin/nologin (создадим пользователя под которым будет запускать)
$ sudo mkdir -p /etc/sysconfig
$ sudo touch /etc/sysconfig/node_exporter
$ sudo nano /etc/systemd/system/node_exporter.service

[Unit]
Description=Node Exporter

[Service]
User=node_exporter
EnvironmentFile=/etc/sysconfig/node_exporter
ExecStart=/usr/bin/prometheus-node-exporter $OPTIONS

[Install]
WantedBy=multi-user.target

* предусмотрите возможность добавления опций к запускаемому процессу через внешний файл (посмотрите, например, на systemctl cat cron),
ExecStart=/usr/bin/prometheus-node-exporter $OPTIONS

* удостоверьтесь, что с помощью systemctl процесс корректно стартует, завершается, а после перезагрузки автоматически поднимается.
$ sudo systemctl daemon-reload
$ sudo systemctl enable node_exporter
$ sudo systemctl start node_exporter

$ /usr/bin/prometheus-node-exporter --version
node_exporter, version 0.18.1+ds (branch: debian/sid, revision: 0.18.1+ds-2)
  build user:       pkg-go-maintainers@lists.alioth.debian.org
  build date:       20200221-05:56:03
  go version:       go1.13.8
  
$ sudo systemctl status node_exporter
● node_exporter.service - Node Exporter
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)
     Active: active (running) 
	 
$ sudo reboot
$ vagrant ssh
$ sudo systemctl status node_exporter
● node_exporter.service - Node Exporter
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)
     Active: active (running) 

$ sudo systemctl stop node_exporter
@vagrant:~$ sudo systemctl status node_exporter
● node_exporter.service - Node Exporter
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)
     Active: inactive (dead)	 
	 
$ sudo systemctl start node_exporter
$ sudo systemctl status node_exporter
● node_exporter.service - Node Exporter
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)
     Active: active (running)

## 2. Ознакомьтесь с опциями node_exporter и выводом /metrics по-умолчанию. Приведите несколько опций, которые вы бы выбрали для базового мониторинга хоста по CPU, памяти, диску и сети.
$ sudo apt install lynx
$ lynx http://localhost:9100/metrics

или

http://192.168.186.130:9100/metrics
скрин прилагается 2022-02-13_001.jpg

---

* CPU - node_cpu*
node_cpu_seconds_total{cpu="0",mode="idle"} 477.43
node_cpu_seconds_total{cpu="0",mode="iowait"} 0.6
node_cpu_seconds_total{cpu="0",mode="system"} 4.99
node_cpu_seconds_total{cpu="0",mode="user"} 1.71
node_cpu_seconds_total{cpu="1",mode="idle"} 479.31
node_cpu_seconds_total{cpu="1",mode="iowait"} 0.14
node_cpu_seconds_total{cpu="1",mode="system"} 3.78
node_cpu_seconds_total{cpu="1",mode="user"} 1.63

* Memory - node_memory*
node_memory_MemAvailable_bytes 6.89033216e+08
node_memory_MemFree_bytes 3.30043392e+08

* Disk - node_disk
node_disk_io_now{device="dm-0"} 0
node_disk_io_now{device="sda"} 0
node_disk_io_now{device="sr0"} 0
node_disk_io_time_seconds_total{device="dm-0"} 4.472
node_disk_io_time_seconds_total{device="sda"} 4.54
node_disk_io_time_seconds_total{device="sr0"} 0

* Network - node_network*
node_network_receive_errs_total{device="eth0"} 
node_network_receive_bytes_total{device="eth0"} 
node_network_transmit_bytes_total{device="eth0"}
node_network_transmit_errs_total{device="eth0"}

## 3. Установите в свою виртуальную машину Netdata. Воспользуйтесь готовыми пакетами для установки (sudo apt install -y netdata). После успешной установки: * в конфигурационном файле /etc/netdata/netdata.conf в секции [web] замените значение с localhost на bind to = 0.0.0.0, добавьте в Vagrantfile проброс порта Netdata на свой локальный компьютер и сделайте vagrant reload: config.vm.network "forwarded_port", guest: 19999, host: 19999

$ sudo apt install -y netdata
$ sudo nano /etc/netdata/netdata.conf 
localhost на bind to = 0.0.0.0
$ systemctl restart netdata

config.vm.network "forwarded_port", guest: 19999, host: 19999
vagrant reload:

http://192.168.186.130:19999/#menu_system_submenu_cpu;theme=slate
2022-02-13_001.jpg

* После успешной перезагрузки в браузере на своем ПК (не в виртуальной машине) вы должны суметь зайти на localhost:19999. Ознакомьтесь с метриками, которые по умолчанию собираются Netdata и с комментариями, которые даны к этим метрикам.

http://192.168.186.130:19999/#menu_system_submenu_cpu;theme=slate
2022-02-13_002.jpg

$ sudo apt install stress
$ stress -c 2 -v -t 100
2022-02-13_003.jpg
2022-02-13_004.jpg

## 4. Можно ли по выводу dmesg понять, осознает ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?
sudo dmesg | grep "Hypervisor detected"
sudo dmesg | grep virtual

# Решение:
vagrant@vagrant:~$ sudo dmesg | grep "Hypervisor detected"
[    0.000000] Hypervisor detected: VMware
vagrant@vagrant:~$ sudo dmesg | grep virtual
[    0.014121] Booting paravirtualized kernel on VMware hypervisor
[    2.721372] systemd[1]: Detected virtualization vmware.

Другие примеры:
* виртуалка
$ sudo dmesg | grep "Hypervisor detected"
[    0.000000] Hypervisor detected: KVM
$ sudo dmesg | grep virtual
[    0.000000] Booting paravirtualized kernel on KVM
[    1.544027] systemd[1]: Detected virtualization bochs.

* виртуалка
$ sudo dmesg | grep "Hypervisor detected"
[    0.000000] Hypervisor detected: KVM
$ sudo dmesg | grep virtual
[    0.087919] Booting paravirtualized kernel on KVM
[    1.863450] systemd[1]: Detected virtualization microsoft.

* железо
$ sudo dmesg | grep "Hypervisor detected"; sudo dmesg | grep virtual
[    0.000000] Booting paravirtualized kernel on bare hardware

Хотя подозреваю, что способ не идеален.. на OpenVZ к примеру dmesg пустой и вывода никакого нет :(

## 5. Как настроен sysctl fs.nr_open на системе по-умолчанию? Узнайте, что означает этот параметр. Какой другой существующий лимит не позволит достичь такого числа (ulimit --help)?

fs.nr_open - максимальное количество открытых файлов в одном процессе
(https://www.kernel.org/doc/html/latest/admin-guide/sysctl/fs.html#nr-open - This denotes the maximum number of file-handles a process can allocate. Default value is 1024*1024 (1048576) which should be enough for most machines. Actual limit depends on RLIMIT_NOFILE resource limit.)

$ cat /etc/sysctl.conf | grep fs.nr_open
ничего не выводит, видимо значение не задано - смотрим

$  /sbin/sysctl -n fs.nr_open
1048576

или

$ cat /proc/sys/fs/nr_open
1048576

* Какой другой существующий лимит не позволит достичь такого числа (ulimit --help)?
Скорее всего речь идет о uname -n -- the maximum number of open file descriptors, но нужно учитывать, что у этого параметра есть hard и soft лимиты, вывод соответственно: 
vagrant@vagrant:~$ ulimit -Hn
1048576
vagrant@vagrant:~$ ulimit -Sn
1024

## 6. Запустите любой долгоживущий процесс (не ls, который отработает мгновенно, а, например, sleep 1h) в отдельном неймспейсе процессов; покажите, что ваш процесс работает под PID 1 через nsenter. Для простоты работайте в данном задании под root (sudo -i). Под обычным пользователем требуются дополнительные опции (--map-root-user) и т.д.

$ sudo -i
root@vagrant:/# unshare -f --pid --mount-proc sleep 1h
^Z
[1]+  Stopped                 unshare -f --pid --mount-proc sleep 1h
root@vagrant:/# ps
    PID TTY          TIME CMD
   1798 pts/0    00:00:00 sudo
   1800 pts/0    00:00:00 bash
  80940 pts/0    00:00:00 sudo
  80941 pts/0    00:00:00 bash
  80971 pts/0    00:00:00 nsenter
  80972 pts/0    00:00:00 bash
  81007 pts/0    00:00:00 unshare
  81008 pts/0    00:00:00 sleep
  81011 pts/0    00:00:00 ps
root@vagrant:/# nsenter --target 81008 --pid --mount
root@vagrant:/# ps
    PID TTY          TIME CMD
      1 pts/0    00:00:00 sleep
      2 pts/0    00:00:00 bash
     13 pts/0    00:00:00 ps

## 7. Найдите информацию о том, что такое :(){ :|:& };:. Запустите эту команду в своей виртуальной машине Vagrant с Ubuntu 20.04 (это важно, поведение в других ОС не проверялось). Некоторое время все будет "плохо", после чего (минуты) – ОС должна стабилизироваться. Вызов dmesg расскажет, какой механизм помог автоматической стабилизации. Как настроен этот механизм по-умолчанию, и как изменить число процессов, которое можно создать в сессии?

Форк бомба:
* :() означает, что вы определяете функцию под названием :
*  {:|: &}означает запустить функцию :и :снова отправить ее вывод в функцию и запустить ее в фоновом режиме.
* ; разделитель команд.
* : запускает функцию в первый раз.

По сути, создаетcя функция, которая вызывает себя дважды при каждом вызове и не имеет возможности завершить себя. Он будет удваиваться, пока не закончатся системные ресурсы.

* Как настроен этот механизм по-умолчанию, и как изменить число процессов, которое можно создать в сессии?
$ dmesg или $ cat /var/log/kern.log
[  484.620433] cgroup: fork rejected by pids controller in /user.slice/user-1000.slice/session-3.scope
[  493.927521] cgroup: fork rejected by pids controller in /user.slice/user-1000.slice/session-1.scope

Если ограничить количество процессов, то эта "волна" проходит гораздо быстрее:
$ ulimit -u 50