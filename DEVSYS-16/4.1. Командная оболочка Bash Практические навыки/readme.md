# Домашнее задание к занятию "4.1. Командная оболочка Bash: Практические навыки"

## Обязательная задача 1

Есть скрипт:
```bash
a=1
b=2
c=a+b
d=$a+$b
e=$(($a+$b))
```

Какие значения переменным c,d,e будут присвоены? Почему?

### Проведем проверку:
```
sku@Angurva:~$ cat task.sh && bash task.sh
#!/bin/bash

a=1
b=2
c=a+b
d=$a+$b
e=$(($a+$b))

echo c - $c
echo d - $d
echo e - $e
```

### Решение

| Переменная  | Значение | Обоснование |
| ------------- | ------------- | ------------- |
| `c`  | a+b  | строка, вывели строку a+b |
| `d`  | 1+2  | тоже строка, объединили строковых значения - вывели два значения, как и в варианте с, но использовали переменные |
| `e`  | 3  | сложили два числа, при двойных уже не строка |


## Обязательная задача 2
На нашем локальном сервере упал сервис и мы написали скрипт, который постоянно проверяет его доступность, записывая дату проверок до тех пор, пока сервис не станет доступным (после чего скрипт должен завершиться). В скрипте допущена ошибка, из-за которой выполнение не может завершиться, при этом место на Жёстком Диске постоянно уменьшается. Что необходимо сделать, чтобы его исправить:
```bash
while ((1==1)
do
	curl https://localhost:4757
	if (($? != 0))
	then
		date >> curl.log
	fi
done
```

### Ваш скрипт:
```bash

while ((1==1))
        do
                curl https://localhost:4757
                if (($? != 0))
                then
                        date >> curl.log
                else
                        echo "service up" >> curl.log
                        break
                fi

done

```

* не хватает скобки
* не хватиет условия выхода из цикла - можем вывести в лог сообщение (для наглядности) и выйти
* или завершить все с помощью exit как альтернатива
* можно добавить sleep в качестве задержки, здесь не делали (не было в условиях)

## Обязательная задача 3
Необходимо написать скрипт, который проверяет доступность трёх IP: `192.168.0.1`, `173.194.222.113`, `87.250.250.242` по `80` порту и записывает результат в файл `log`. Проверять доступность необходимо пять раз для каждого узла.

### Ваш скрипт:
```bash
ip=("192.168.1.27" "192.168.1.43" "192.168.1.35")
port=80
check=5
log=log.log
dt=$(date)

#clear file
truncate -s 0 $log

while (($check > 0))
do
  for i in ${ip[@]}
    do
	  echo -n $dt "- ">> $log 
	  nc -zv $i $port &>> $log
    done
    let "check=check-1"
done
```

На выходе получаем лог:
```
sku@Angurva:~$ cat -n log.log
     1  Sat Mar 12 07:29:23 MSK 2022 - Connection to 192.168.1.27 80 port [tcp/http] succeeded!
     2  Sat Mar 12 07:29:23 MSK 2022 - Connection to 192.168.1.43 80 port [tcp/http] succeeded!
     3  Sat Mar 12 07:29:23 MSK 2022 - nc: connect to 192.168.1.35 port 80 (tcp) failed: Connection refused
     4  Sat Mar 12 07:29:23 MSK 2022 - Connection to 192.168.1.27 80 port [tcp/http] succeeded!
     5  Sat Mar 12 07:29:23 MSK 2022 - Connection to 192.168.1.43 80 port [tcp/http] succeeded!
     6  Sat Mar 12 07:29:23 MSK 2022 - nc: connect to 192.168.1.35 port 80 (tcp) failed: Connection refused
     7  Sat Mar 12 07:29:23 MSK 2022 - Connection to 192.168.1.27 80 port [tcp/http] succeeded!
     8  Sat Mar 12 07:29:23 MSK 2022 - Connection to 192.168.1.43 80 port [tcp/http] succeeded!
     9  Sat Mar 12 07:29:23 MSK 2022 - nc: connect to 192.168.1.35 port 80 (tcp) failed: Connection refused
    10  Sat Mar 12 07:29:23 MSK 2022 - Connection to 192.168.1.27 80 port [tcp/http] succeeded!
    11  Sat Mar 12 07:29:23 MSK 2022 - Connection to 192.168.1.43 80 port [tcp/http] succeeded!
    12  Sat Mar 12 07:29:23 MSK 2022 - nc: connect to 192.168.1.35 port 80 (tcp) failed: Connection refused
    13  Sat Mar 12 07:29:23 MSK 2022 - Connection to 192.168.1.27 80 port [tcp/http] succeeded!
    14  Sat Mar 12 07:29:23 MSK 2022 - Connection to 192.168.1.43 80 port [tcp/http] succeeded!
    15  Sat Mar 12 07:29:23 MSK 2022 - nc: connect to 192.168.1.35 port 80 (tcp) failed: Connection refused
```

или можно тоже самое изобразить с помощью for и проверку проводить через curl

```bash
ip=("192.168.1.27" "192.168.1.43" "192.168.1.35")
port=80
check=5
log=log.log
dt=$(date)

#clear file
truncate -s 0 $log

for i in {1..5}
	do
		for ii in ${ip[@]}
			do 
				echo -n $dt "- " >> $log 
				curl -Is $ii:$port >/dev/null
				echo check result for $ii = $?  >> $log 
			done
	done	
```

На выходе получаем лог:
```
sku@Angurva:~$ cat -n log.log
     1  Sat Mar 12 07:45:05 MSK 2022 - check result for 192.168.1.27 = 0
     2  Sat Mar 12 07:45:05 MSK 2022 - check result for 192.168.1.43 = 0
     3  Sat Mar 12 07:45:05 MSK 2022 - check result for 192.168.1.35 = 7
     4  Sat Mar 12 07:45:05 MSK 2022 - check result for 192.168.1.27 = 0
     5  Sat Mar 12 07:45:05 MSK 2022 - check result for 192.168.1.43 = 0
     6  Sat Mar 12 07:45:05 MSK 2022 - check result for 192.168.1.35 = 7
     7  Sat Mar 12 07:45:05 MSK 2022 - check result for 192.168.1.27 = 0
     8  Sat Mar 12 07:45:05 MSK 2022 - check result for 192.168.1.43 = 0
     9  Sat Mar 12 07:45:05 MSK 2022 - check result for 192.168.1.35 = 7
    10  Sat Mar 12 07:45:05 MSK 2022 - check result for 192.168.1.27 = 0
    11  Sat Mar 12 07:45:05 MSK 2022 - check result for 192.168.1.43 = 0
    12  Sat Mar 12 07:45:05 MSK 2022 - check result for 192.168.1.35 = 7
    13  Sat Mar 12 07:45:05 MSK 2022 - check result for 192.168.1.27 = 0
    14  Sat Mar 12 07:45:05 MSK 2022 - check result for 192.168.1.43 = 0
    15  Sat Mar 12 07:45:05 MSK 2022 - check result for 192.168.1.35 = 7
```

## Обязательная задача 4
Необходимо дописать скрипт из предыдущего задания так, чтобы он выполнялся до тех пор, пока один из узлов не окажется недоступным. Если любой из узлов недоступен - IP этого узла пишется в файл error, скрипт прерывается.

### Ваш скрипт:
```bash
ip=("192.168.1.27" "192.168.1.43" "192.168.1.35")
port=80
check=5
log=log.log
dt=$(date)

#clear file
truncate -s 0 $log

for ii in ${ip[@]}
			do 
				curl -Is $ii:$port >/dev/null
				 if (($? != 0))
					then
						echo -n $dt "- " >> $log 
						curl -Is $ii:$port >/dev/null
						echo check result for $ii = $?  >> $log 
						break
				fi		
			done
```

На выходе получаем лог:
```
sku@Angurva:~$ cat -n log.log
	1  Sat Mar 12 08:00:38 MSK 2022 - check result for 192.168.1.35 = 7
```
