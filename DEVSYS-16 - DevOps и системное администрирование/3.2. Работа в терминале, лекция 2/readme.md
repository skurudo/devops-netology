# 3.2. Работа в терминале, лекция 2

## 1. Какого типа команда cd? Попробуйте объяснить, почему она именно такого типа; опишите ход своих мыслей, если считаете что она могла бы быть другого типа.
$ type cd
cd is a shell builtin

встроенная в шелл команда, без оболочки нет и этой команды... возможно смена директорий могла бы быть реализована и в виду какой-то внешней утилитой - чем-то вроде ncdu но без размеров, где при запуске мы бы смотрели в файловую систему от корня или с домашней директории... но это была бы совсем другая, более непривычная история

## 2. Какая альтернатива без pipe команде grep <some_string> <some_file> | wc -l? man grep поможет в ответе на этот вопрос. Ознакомьтесь с документом о других подобных некорректных вариантах использования pipe.
grep -c

#РЕШЕНИЕ:
$ nano test2.txt
$ grep 123 test2.txt
123
123
123
123
312312
123
vagrant@vagrant:~$ grep 123 test2.txt | wc -l
6
vagrant@vagrant:~$ grep 123 test2.txt -c
6

## 3. Какой процесс с PID 1 является родителем для всех процессов в вашей виртуальной машине Ubuntu 20.04?
systemd

Первый процесс в системе запускается при инициализации ядра, он называется - init (исторически) и этот результат мы можем видеть в ps aux... но в связи с разнитием systemd видимо init стал частью монстра

#РЕШЕНИЕ:
$ pstree -p
systemd(1)─

$ cat /proc/1/stat
1 (systemd) S 0 1 1 0 -1 

$ sudo ps  aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  1.2 168744 12780 ?        Ss   18:17   0:03 /sbin/init

## 4. Как будет выглядеть команда, которая перенаправит вывод stderr ls на другую сессию терминала?
общий случай:
ls 2> /dev/pts/X 
(где Х идентификатор сессии терминала)

тест с наличием ошибки:
ls  /mydir 2> /dev/pts/X 
(где Х идентификатор сессии терминала)

#РЕШЕНИЕ:
сначала нам нужно иметь другую сессию терминала

$ pinky
Login    Name                 TTY      Idle   When             Where
vagrant  vagrant              pts/0           2022-02-03 18:18 192.168.186.2
vagrant  vagrant              pts/1           2022-02-05 02:22 192.168.186.2

далее можно перенаправлять:
$ ls > /dev/pts/1
в задании речь идет об stderr - создадим ситуацию с ошибкой
$ ls  /mydir 2> /dev/pts/1

но перенаправление в соседний терминал не пройдет:
ls 2> /dev/pts/1 -- тут нет ошибки, отработает локально
ls  /mydir > /dev/pts/1 -- а тут нет перенаправления именно ошибок, оно выполнится в твоей же сессии,

## 5. Получится ли одновременно передать команде файл на stdin и вывести ее stdout в другой файл? Приведите работающий пример.
ls -la < test 1 > test2
или так
ls -la > test1 && cat < test1 > test2

## 6. Получится ли находясь в графическом режиме, вывести данные из PTY в какой-либо из эмуляторов TTY? Сможете ли вы наблюдать выводимые данные?
Скорее всего сможем, да, если перенаправим поток.. только проверить не получилось именно в графическом режиме :(

Пример:
$ sudo echo test >/dev/pts/2
..и в соседнем терминале:
vagrant@vagrant:~$ tty
/dev/pts/2
vagrant@vagrant:~$ test

## 7. Выполните команду bash 5>&1. К чему она приведет? Что будет, если вы выполните echo netology > /proc/$$/fd/5? Почему так происходит?
$ bash 5>&1 <-- создаем новый дескриптор 5
$ echo netology > /proc/$$/fd/5 <-- вывод команды echo будет перенаправлен в дескриптор, который мы создали выше и также в stdout

причем все это мы делаем в рамках текущией сессии, потому что попытка сделать тоже самое в другой сессии выдаст нам ошибку, т.е. нет дескриптора:
vagrant@vagrant:~$ cat  echo netology > /proc/$$/fd/5
-bash: /proc/59878/fd/5: No such file or directory

## 8. Получится ли в качестве входного потока для pipe использовать только stderr команды, не потеряв при этом отображение stdout на pty? Напоминаем: по умолчанию через pipe передается только stdout команды слева от | на stdin команды справа. Это можно сделать, поменяв стандартные потоки местами через промежуточный новый дескриптор, который вы научились создавать в предыдущем вопросе.

la -la 6>&1 1>&2 2>&6 | wc -l
*  сама команда
*  перенаправление в новый дескриптор
*  перенаправление stderr в stdout
*  перенаправление stdout в новый дескриптор

## 9. Что выведет команда cat /proc/$$/environ? Как еще можно получить аналогичный по содержанию вывод?
переменные окружения и их значения 
(из описания: * Переменная environ указывает на массив строк, называемый `environment' (окружение))

аналогичные данные можно получить командами env и printenv

## 10. Используя man, опишите что доступно по адресам /proc/<PID>/cmdline, /proc/<PID>/exe.
/proc/<PID>/cmdline - файл только для чтения, который содержит полную информацию о процессе из командной строки
/proc/<PID>/exe - символическая ссылка на фактически работающую программу

## 11. Узнайте, какую наиболее старшую версию набора инструкций SSE поддерживает ваш процессор с помощью /proc/cpuinfo.
sse4_2

#РЕШЕНИЕ:
* SSE (англ. Streaming SIMD Extensions, потоковое SIMD-расширение процессора) 
cat /proc/cpuinfo | grep sse
старшая, судя по флагам, для Intel(R) Core(TM) i9-10900 CPU @ 2.80GHz -> sse4_2

## 12. При открытии нового окна терминала и vagrant ssh создается новая сессия и выделяется pty. Это можно подтвердить командой tty, которая упоминалась в лекции 3.2. Однако: vagrant@netology1:~$ ssh localhost 'tty' not a tty - Почитайте, почему так происходит, и как изменить поведение.

Приведено верное поведение:
vagrant@vagrant:~$ tty
	/dev/pts/0
vagrant@vagrant:~$ ssh localhost 'tty'
vagrant@localhost's password:
	not a tty

Стоит использовать ssh с опцией -t, тогда произойдет "переназначение терминала, даже если ssh не имеет локального терминала"
	
vagrant@vagrant:~$ ssh  -t localhost 'tty'
vagrant@localhost's password:
/dev/pts/3
Connection to localhost closed

## 13. Бывает, что есть необходимость переместить запущенный процесс из одной сессии в другую. Попробуйте сделать это, воспользовавшись reptyr. Например, так можно перенести в screen процесс, который вы запустили по ошибке в обычной SSH-сессии.

У нас нет похоже reptyr, установим:
vagrant@vagrant:~$ reptyr
bash: reptyr: command not found

vagrant@vagrant:~$ sudo apt install reptyr

Запустим две разных сессии, в одной из них запустим ping
vagrant@vagrant:~$ ping 1.1.1.1

В соседней сессии смотрим pid процесса
$ ps aux | grep mc
vagrant     1470  0.0  0.8  17656  8428 pts/1    T    19:04   0:00 mc

Пробуем захватить, но не очень удачно:
vagrant@vagrant:~$ reptyr 1470
Unable to attach to pid 1470: Operation not permitted
The kernel denied permission while attaching. If your uid matches
the target's, check the value of /proc/sys/kernel/yama/ptrace_scope.
For more information, see /etc/sysctl.d/10-ptrace.conf

Смотрим на ошибку и правим ptrace_scope:
sudo nano /proc/sys/kernel/yama/ptrace_scope

ctrl +z

vagrant@vagrant:~$ reptyr 1470

И процесс перехвачен успешно.

## 14. sudo echo string > /root/new_file не даст выполнить перенаправление под обычным пользователем, так как перенаправлением занимается процесс shell'а, который запущен без sudo под вашим пользователем. Для решения данной проблемы можно использовать конструкцию echo string | sudo tee /root/new_file. Узнайте что делает команда tee и почему в отличие от sudo echo команда с sudo tee будет работать.

tee - записывает в файл (чтение со стандартного ввода и запись на стандартный вывод и файлы)
echo - выводит информацию на экран

tee является отдельной программой, а echo встроенной в шелл

vagrant@vagrant:~$ type echo
echo is a shell builtin
vagrant@vagrant:~$ type tee
tee is /usr/bin/tee