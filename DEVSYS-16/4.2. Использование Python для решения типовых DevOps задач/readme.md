# Домашнее задание к занятию "4.2. Использование Python для решения типовых DevOps задач"

## Обязательная задача 1

Есть скрипт:
```python
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```

### Вопросы:
| Вопрос  | Ответ |
| ------------- | ------------- |
| Какое значение будет присвоено переменной `c`?  | ошибка, сложить цифры и строки не дано  |
| Как получить для переменной `c` значение 12?  | c=str(a)+b - сложим строки  |
| Как получить для переменной `c` значение 3?  | c=a+int(b) - сложим цифры  |

Тесты в файле - test.py

## Обязательная задача 2
Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/devops-netology", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
#is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(os.path.abspath(prepare_result))
#        break
```

### Вывод скрипта при запуске при тестировании:
** (в репо ничего не менялось, потому внесли изменения, чтобы увидеть что-нибудь)

```python
sku@Angurva:~$ ./git-change.py
/home/sku/README.md
```

## Обязательная задача 3
1. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

### Ваш скрипт:
```python
#!/usr/bin/env python3
print("Введите полный путь к репозиторию(со знаком '/' в конце):")
path = input()

import os

os.chdir(path)
bash_command = ["git status"]
result_os = os.popen(' && '.join(bash_command)).read()
#is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(path+prepare_result)
#        break
```

### Вывод скрипта при запуске при тестировании:
```
sku@Angurva:~$ ./git-change2.py
Введите полный путь к репозиторию(со знаком '/' в конце):
/home/sku/devops-netology/
/home/sku/devops-netology/README.md
```

## Обязательная задача 4
1. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: `drive.google.com`, `mail.google.com`, `google.com`.

### Ваш скрипт:
```python
#!/usr/bin/env python3
import socket

check_names=["drive.google.com", "mail.google.com", "google.com"]
check_ip=["0.0.0.0", "0.0.0.0", "0.0.0.0"]

for i in range(0, 3):
    check_ip[i] = socket.gethostbyname(check_names[i])
    print(check_names[i] + ' - ' + check_ip[i])
 
    z=0
    while z<100:
        for i in range(0, 3):
            if check_ip[i] != socket.gethostbyname(check_names[i]):
                print("EROR", check_names[i], " IP mismatch: ", check_ip[i], socket.gethostbyname(check_names[i]))
            else:
                print(check_names[i] + ' - ' + check_ip[i])
    z=z+1
```

### Вывод скрипта при запуске при тестировании:
```
drive.google.com - 64.233.162.194
mail.google.com - 74.125.131.83
google.com - 64.233.162.100
drive.google.com - 64.233.162.194
mail.google.com - 74.125.131.83
google.com - 64.233.162.100
drive.google.com - 64.233.162.194
mail.google.com - 74.125.131.83
google.com - 64.233.162.100

... и через некоторое время можно наблюдать такое:

drive.google.com - 64.233.162.194
EROR mail.google.com  IP mismatch:  74.125.131.19 74.125.131.83
EROR google.com  IP mismatch:  64.233.162.138 64.233.162.100
drive.google.com - 64.233.162.194
EROR mail.google.com  IP mismatch:  74.125.131.19 74.125.131.83
EROR google.com  IP mismatch:  64.233.162.138 64.233.162.100
drive.google.com - 64.233.162.194
EROR mail.google.com  IP mismatch:  74.125.131.19 74.125.131.83
EROR google.com  IP mismatch:  64.233.162.138 64.233.162.100
drive.google.com - 64.233.162.194
EROR mail.google.com  IP mismatch:  74.125.131.19 74.125.131.83
EROR google.com  IP mismatch:  64.233.162.138 64.233.162.100
drive.google.com - 64.233.162.194
EROR mail.google.com  IP mismatch:  74.125.131.19 74.125.131.83
EROR google.com  IP mismatch:  64.233.162.138 64.233.162.100
drive.google.com - 64.233.162.194
EROR mail.google.com  IP mismatch:  74.125.131.19 74.125.131.83
EROR google.com  IP mismatch:  64.233.162.138 64.233.162.100
drive.google.com - 64.233.162.194
EROR mail.google.com  IP mismatch:  74.125.131.19 74.125.131.83
EROR google.com  IP mismatch:  64.233.162.138 64.233.162.100
drive.google.com - 64.233.162.194
EROR mail.google.com  IP mismatch:  74.125.131.19 74.125.131.83
EROR google.com  IP mismatch:  64.233.162.138 64.233.162.100
drive.google.com - 64.233.162.194
EROR mail.google.com  IP mismatch:  74.125.131.19 74.125.131.83
EROR google.com  IP mismatch:  64.233.162.138 64.233.162.100
drive.google.com - 64.233.162.194
EROR mail.google.com  IP mismatch:  74.125.131.19 74.125.131.83
```


