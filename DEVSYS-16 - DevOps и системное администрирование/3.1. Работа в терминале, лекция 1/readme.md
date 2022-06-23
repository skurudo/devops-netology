# 3.1. Работа в терминале, лекция 1

## 1. Установите средство виртуализации Oracle VirtualBox.
done

## 2. Установите средство автоматизации Hashicorp Vagrant.
done 

## 3. В вашем основном окружении подготовьте удобный для дальнейшей работы терминал. Можно предложить:
done - windows terminal
хотя из powershell тоже можно работать (команды выполняются)

## 4. С помощью базового файла конфигурации запустите Ubuntu 20.04 в VirtualBox посредством Vagrant:
cd .\Documents\devops\bento-ubuntu-2004\
vagrant init
file edit
vagrant up
проверили vagrant suspend и vagrant halt с последующим up

## 5. Ознакомьтесь с графическим интерфейсом VirtualBox, посмотрите как выглядит виртуальная машина, которую создал для вас Vagrant, какие аппаратные ресурсы ей выделены. Какие ресурсы выделены по-умолчанию?
done

vagrant ssh
cat /proc/cpuinfo - 2 ядра
cat /proc/meminfo - 1024Мб (1004576 kB)
fdisk -l -- 64Гб

с данными в графическом интерфейсе совпадает

## 6. Ознакомьтесь с возможностями конфигурации VirtualBox через Vagrantfile: документация. Как добавить оперативной памяти или ресурсов процессора виртуальной машине?
v.memory = 1024 -- соотвественно здесь указать 2048 или выше
v.cpus = 2 -- указать больше
https://www.vagrantup.com/docs/providers/virtualbox/configuration

В итоге у нас получается следующий Vagrantfile:
Vagrant.configure("2") do |config|
 	config.vm.box = "bento/ubuntu-20.04"

	config.vm.provider "virtualbox" do |v|
	v.memory = 2048
	v.cpus = 3
	end     
end

Проверяем:
vagrant halt
-edit Vagrantfile
vagrant ssh 
cat /proc/cpuinfo - 3 ядра
cat /proc/meminfo - 2048Мб (2035012 kB)
откатили изменения
vagrant reload

## 7. Команда vagrant ssh из директории, в которой содержится Vagrantfile, позволит вам оказаться внутри виртуальной машины без каких-либо дополнительных настроек. Попрактикуйтесь в выполнении обсуждаемых команд в терминале Ubuntu.
done

## 8. Ознакомиться с разделами man bash, почитать о настройках самого bash:
* какой переменной можно задать длину журнала history, и на какой строчке manual это описывается?
HISTSIZE, но стоит также учитывать HISTFILESIZE
делается к примеру так:
$ export HISTSIZE=1000
$ export HISTFILESIZE=1000

$ man bash | grep -n size
2399:       history-size (unset)

* что делает директива ignoreboth в bash?
$ man bash | grep -n ignoreboth
- A value of ignoreboth is shorthand for ignorespace and ignoredups
- игнорировать пробелы и дубли команд

## 9. В каких сценариях использования применимы скобки {} и на какой строчке man bash это описано?
160:       ! case  coproc  do done elif else esac fi for function if in select then until while { } time [[ ]]
228:       { list; }

то, что находится между фигурными скобками - выполняется в контексте текущей оболочки,
но можно использовать круглые скобки и выполнять в отдельном подпроцессе

## 10. С учётом ответа на предыдущий вопрос, как создать однократным вызовом touch 100000 файлов? Получится ли аналогичным образом создать 300000? Если нет, то почему?
$ touch {000001..100000}.txt
$ find . -type f -name "*.txt" | wc
 100000  

$ touch {000001..300000}.txt
-bash: /usr/bin/touch: Argument list too long
получаем мы ее потому, что ARG_MAX у нас 2097152 ($ getconf ARG_MAX или xargs --show-limits)

## 11. В man bash поищите по /\[\[. Что делает конструкция [[ -d /tmp ]]
* Условные выражения используются составной командой [[ ]] и встроенными командами test и [ ] для проверки атрибутов файла и выполнения
при существовании директории вернет нам положительное значение, true... -- если точнее, возвращается 1 или 0 (true/false это больше программиские шаблоны желаемого ответа)... под положительным имелось в виду true - не значение

*...на самом деле тут путаются понятия  true/false c success/failure. Нужно оперировать, пожалуй, последними, т.к. true/false нет здесь, если не задекларировано иное. Успешная операция вернет 0, ошибка 1.

true - success - всегда возвращает 0 в качестве кода выхода.
false - failure - всегда возвращает 1 в качестве кода выхода.

источник по test говорит нам:
-d FILE
       FILE exists and is a directory

например:
if [[ -d /tmp ]]; then
    echo "exist - code $?"
                else
                echo "do not exist - code $?"
fi
$ bash test.sh
exist - code 0

например 2:
if [[ -d /tmp ]]; then
    echo "exist - code $?"
                else
                echo "do not exist - code $?"
fi
$ bash test.sh
do not exist - code 1

-- доп проверка идей:
Существующий каталог:
```
sku@Angurva:~$ cat test.sh
#!/bin/bash

if [[ -d /tmp ]]; then
    echo "exist - code $?"
                else
                echo "do not exist - code $?"
fi

**sku@Angurva:~$ bash test.sh
exist - code 0**
```

Несуществующий каталог:
```
sku@Angurva:~$ cat test.sh
#!/bin/bash

if [[ -d /tmp2 ]]; then
    echo "exist - code $?"
                else
                echo "do not exist - code $?"
fi

**sku@Angurva:~$ bash test.sh
do not exist - code 1**
```

Но опять же, если настаиваете, то переписал скрипт еще проще, без всяких там if else..
```
#!/bin/bash

[[ -d /tmp2 ]]
echo "$?"
echo "do not exist, status above"

[[ -d /tmp ]]
echo "$?"
echo "exist, status above"
```
**Результат:**
```
[[ -d /tmp2 ]]
echo "$?"
echo "do not exist, status above"

[[ -d /tmp ]]
echo "$?"
echo "exist, status above"
```


## 12. Основываясь на знаниях о просмотре текущих (например, PATH) и установке новых переменных; командах, которые мы рассматривали, добейтесь в выводе type -a bash в виртуальной машине наличия первым пунктом в списке:
* bash is /tmp/new_path_directory/bash
* bash is /usr/local/bin/bash
* bash is /bin/bash
* (прочие строки могут отличаться содержимым и порядком) В качестве ответа приведите команды, которые позволили вам добиться указанного вывода или соответствующие скриншоты.

$ mkdir /tmp/new_path_directory
$ cp /bin/bash /tmp/new_path_directory/ && sudo cp /bin/bash /usr/local/bin/
$ export PATH=/tmp/new_path_directory:/usr/local/bin:$PATH

$ type -a bash
bash is /tmp/new_path_directory/bash
bash is /usr/local/bin/bash
bash is /bin/bash

## 13. Чем отличается планирование команд с помощью batch и at?
команда batch — для назначения одноразовых задач, которые должны выполняться, когда загрузка системы становится меньше 0,8
команда at - назначает выполнение разового задания в определённое время (время, полноч, день, четыре часа дня, дата (ММДДГГ), сейчас для время - за это отвечает параметр time)

## 14. Завершите работу виртуальной машины чтобы не расходовать ресурсы компьютера и/или батарею ноутбука.
vagrant halt
