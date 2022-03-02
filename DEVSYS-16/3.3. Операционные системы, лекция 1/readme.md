# 3.3. Операционные системы, лекция 1

## 1. Какой системный вызов делает команда cd? В прошлом ДЗ мы выяснили, что cd не является самостоятельной программой, это shell builtin, поэтому запустить strace непосредственно на cd не получится. Тем не менее, вы можете запустить strace на /bin/bash -c 'cd /tmp'. В этом случае вы увидите полный список системных вызовов, которые делает сам bash при старте. Вам нужно найти тот единственный, который относится именно к cd. Обратите внимание, что strace выдаёт результат своей работы в поток stderr, а не в stdout.

$strace bash -c 'cd /etc'
chdir("/etc")

## 2. Попробуйте использовать команду file на объекты разных типов на файловой системе. Используя strace выясните, где находится база данных file на основании которой она делает свои догадки.

База лежит здесь - /usr/share/misc/magic.mgc

#РЕШЕНИЕ
$ strace file /bin/bash

в выводе находим:
stat("/home/vagrant/.magic.mgc", 0x7ffe7f1a9660) = -1 ENOENT (No such file or directory)
stat("/home/vagrant/.magic", 0x7ffe7f1a9660) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/etc/magic.mgc", O_RDONLY) = -1 ENOENT (No such file or directory)
stat("/etc/magic", {st_mode=S_IFREG|0644, st_size=111, ...}) = 0
openat(AT_FDCWD, "/etc/magic", O_RDONLY) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=111, ...}) = 0
read(3, "# Magic local data for file(1) c"..., 4096) = 111
read(3, "", 4096)                       = 0
close(3)                                = 0
openat(AT_FDCWD, "/usr/share/misc/magic.mgc", O_RDONLY) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=5811536, ...}) = 0

## 3. Предположим, приложение пишет лог в текстовый файл. Этот файл оказался удален (deleted в lsof), однако возможности сигналом сказать приложению переоткрыть файлы или просто перезапустить приложение – нет. Так как приложение продолжает писать в удаленный файл, место на диске постепенно заканчивается. Основываясь на знаниях о перенаправлении потоков предложите способ обнуления открытого удаленного файла (чтобы освободить место на файловой системе).

$ ping 1.1.1.1 > 1.log & rm 1.log
[2] 17770
 
$ sudo lsof -p 17770 | grep del
ping    17770 vagrant    1w   REG  253,0     3004 266267 /home/vagrant/1.log (deleted)

* уменьшение размера файла
$ sudo echo '' >/proc/17770/fd/4
или 
$ sudo truncate -s 0 /proc/17770/fd/4

-----

vagrant@vagrant:~$ ping 1.1.1.1 > 1.log & rm 1.log
[2] 1648

vagrant@vagrant:~$ sudo lsof -p 1648 | grep del
ping    1648 vagrant    1w   REG  253,0     3340 262197 /home/vagrant/1.log (deleted)

vagrant@vagrant:~$ sudo ls -la /proc/1648/fd

* уменьшение размера файла
sudo truncate -s 0 /proc/1648/fd/1
или
sudo -i | echo '' >/proc/1648/fd/1
  
## 4. Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?
Нет, не занимают. Однако они занимают записи в таблице процессов ядра, в следствии чего можно упереться в лимиты threads-max

Например в тестовой ОС у нас это - 7141:
vagrant@vagrant:~$ cat /proc/sys/kernel/threads-max
7141

## 5. В iovisor BCC есть утилита opensnoop: root@vagrant:~# dpkg -L bpfcc-tools | grep sbin/opensnoop /usr/sbin/opensnoop-bpfcc На какие файлы вы увидели вызовы группы open за первую секунду работы утилиты? Воспользуйтесь пакетом bpfcc-tools для Ubuntu 20.04. Дополнительные сведения по установке - https://github.com/iovisor/bcc/blob/master/INSTALL.md

$ sudo apt install bpfcc-tools

vagrant@vagrant:~$ sudo /usr/sbin/opensnoop-bpfcc
PID    COMM               FD ERR PATH
585    multipathd          8   0 /sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/state
585    multipathd          8   0 /sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/size
585    multipathd          8   0 /sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/state
585    multipathd         -1   2 /sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/vpd_pg80
585    multipathd         -1   2 /sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/vpd_pg83
394    systemd-journal    28   0 /proc/585/status
394    systemd-journal    28   0 /proc/585/status
394    systemd-journal    28   0 /proc/585/comm
394    systemd-journal    28   0 /proc/585/cmdline
394    systemd-journal    28   0 /proc/585/status
394    systemd-journal    28   0 /proc/585/attr/current
394    systemd-journal    28   0 /proc/585/sessionid
394    systemd-journal    28   0 /proc/585/loginuid
394    systemd-journal    28   0 /proc/585/cgroup
394    systemd-journal    -1   2 /run/systemd/units/log-extra-fields:multipathd.service
394    systemd-journal    28   0 /var/log/journal/6b3e999fb11342719a282568b23b00f8
394    systemd-journal    -1   2 /run/log/journal/6b3e999fb11342719a282568b23b00f8/system.journal
394    systemd-journal    -1   2 /run/log/journal/6b3e999fb11342719a282568b23b00f8/system.journal
394    systemd-journal    -1   2 /run/log/journal/6b3e999fb11342719a282568b23b00f8/system.journal
394    systemd-journal    -1   2 /run/log/journal/6b3e999fb11342719a282568b23b00f8/system.journal

## 6. Какой системный вызов использует uname -a? Приведите цитату из man по этому системному вызову, где описывается альтернативное местоположение в /proc, где можно узнать версию ядра и релиз ОС.
arch_prctl
/proc/sys/kernel/{ostype, hostname, osrelease, version, domainname}

#Решение
$ strace uname -a
arch_prctl(ARCH_SET_FS, 0x7fa28f66d580) = 0

$ apt install manpages-dev
$ man uname
$ man 2 uname | grep proc
       Part of the utsname information is also accessible via /proc/sys/kernel/{ostype, hostname, osrelease, version, domainname}.

## 7. Чем отличается последовательность команд через ; и через && в bash? Например:
## root@netology1:~ test -d /tmp/some_dir; echo Hi -> Hi
## root@netology1:~ test -d /tmp/some_dir && echo Hi -> root@netology1:~
## Есть ли смысл использовать в bash &&, если применить set -e?

# про ;
; -- разделитель последовательности команд

например:
$ echo "1"; cd /somedir; echo "2";

Вывод:
1
-bash: cd: /somedir: No such file or directory
2

Мы выполним последовательно все команды

# про &&
&& -- условный оператор для последовательного выполнения команд

например:
$ echo "1" && cd /somedir && echo "2"

Вывод:
1
-bash: cd: /somedir: No such file or directory

Команды выполняются последовательно до тех пор пока не наткнемся на ошибку при выполнении. Увидели выполнение первой команды, вторая с ошибкой и echo "2" уже не выполненилась.

# про set -e
Оболочка/скрипт немедленно заваршается в том случае, если конвейер из одной команды, списка или состановной команды возввращает ненулевой статус (* set -e (errexit): Abort the script at the first error, when a command exits with non-zero status (except in until or while loops, if-tests, and list constructs) * - plus  https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html). Сценариев для совместного использования не вижу.

## 8. Из каких опций состоит режим bash set -euxo pipefail и почему его хорошо было бы использовать в сценариях?

* e - прерываем выполнение в случае ненулевого значения, ошибка
A simple command that has a non-zero exit status causes the shell to exit unless the simple command is:

* u - показываем ошибки
If enabled, the shell displays an error message when it tries to expand a variable that is unset.

* x - вывод трейса
Execution trace. The shell displays each command after all expansion and before execution preceded by the expanded value of the PS4 parameter.

* o - опции, в данном случае у нас тут pipefail
If option is not specified, the list of options and their current settings is written to standard output. When invoked with a + the options are written in a format that can be input again to the shell to restore the settings. This option can be repeated to enable or disable multiple options.

* pipefail - возввращает код возврата
A pipeline does not complete until all components of the pipeline have completed, and the exit status of the pipeline is the value of the last command to exit with non-zero exit status, or is zero if all commands return zero exit status.

## 9. Используя -o stat для ps, определите, какой наиболее часто встречающийся статус у процессов в системе. В man ps ознакомьтесь (/PROCESS STATE CODES) что значат дополнительные к основной заглавной буквы статуса процессов. Его можно не учитывать при расчете (считать S, Ss или Ssl равнозначными).

Больше всего значений S, процессы в ожидании, режим сна
Вторые по количеству I, фоновые процессы

#Параметры STAT
R : процесс выполняется в данный момент;
S : процесс ожидает (т.е. спит менее 20 секунд);
I : процесс бездействует (т.е. спит больше 20 секунд);
D : процесс ожидает ввода-вывода (или другого недолгого события), непрерываемый;
Z : zombie или defunct процесс, то есть завершившийся процесс, код возврата которого пока не считан родителем;
T : процесс остановлен;
W : процесс в свопе;
< : процесс в приоритетном режиме;
N : процесс в режиме низкого приоритета;
L : real-time процесс, имеются страницы, заблокированные в памяти;
s : лидер сессии.

# Уникальные значения в STAT
vagrant@vagrant:~$ ps aux | awk {'print $8'} | sort -u
I
I<
R+
S
S+
S<
SLsl
SN
S<s
Ss
Ss+
Ssl

# Подсчет значений:
vagrant@vagrant:~$ ps aux | awk {'print $8'} | sort | uniq -c
      8 I
     39 I<
      1 R+
     58 S
      3 S+
      7 S<
      1 SLsl
      2 SN
      1 S<s
     14 Ss
      1 Ss+
      9 Ssl
	  
vagrant@vagrant:~$ ps aux | awk {'print $8'} | sort | uniq -w 1 -c
     48 I
      1 R+
    109 S
      4 T