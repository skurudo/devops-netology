# Домашнее задание к занятию "08.01 Введение в Ansible"

## Подготовка к выполнению
#### 1. Установите ansible версии 2.10 или выше.

```
vagrant@dev-ansible:~$ sudo apt-get update

vagrant@dev-ansible:~$ sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

vagrant@dev-ansible:~$ sudo mkdir -p /etc/apt/keyrings

vagrant@dev-ansible:~$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg    

 vagrant@dev-ansible:~$ echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

vagrant@dev-ansible:~$ sudo apt-get update

vagrant@dev-ansible:~$ sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

vagrant@dev-ansible:~$ sudo apt-get install ansible

vagrant@dev-ansible:~$ ansible --version
ansible 2.9.6
```

#### 2. Создайте свой собственный публичный репозиторий на github с произвольным именем.

* https://github.com/skurudo/devops-netology-tests/

#### 3. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.

```
  git clone https://github.com/skurudo/devops-netology-tests/
  cd devops-netology-tests/
  git config --global user.name "PG"
  git config --global user.email pavel@galkin.su
  git init
  ssh-keygen
  cat /home/vagrant/.ssh/id_rsa.pub
  git init
  git add .
  git commit -a -m 'first commit'
  git remote add origin git@github.com:skurudo/devops-netology-tests.git
  git remote -v
  git remote remove origin
  git remote add origin git@github.com:skurudo/devops-netology-tests.git
  git remote -v
  git push -u origin master
```

## Основная часть
#### 1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.

```
 vagrant@dev-ansible:~/devops-netology-tests/ansible/81$ ansible-playbook -i inventory/test.yml site.yml

PLAY [Print os facts] ******************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************
ok: [localhost]

TASK [Print OS] ************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] **********************************************************************************************************
ok: [localhost] => {
    "msg": 12
}

PLAY RECAP *****************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

#### 2. Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.

```
cat /group_vars/all/examp.yml 

---
  some_fact: all default fact
```

#### 3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.

```
vagrant@dev-ansible:~/devops-netology-tests/ansible/81$ sudo service docker start
vagrant@dev-ansible:~/devops-netology-tests/ansible/81$ sudo service docker status
```

```
sudo docker run --name centos7 -d pycontribs/centos:7 sleep 36000000 && sudo docker run --name ubuntu -d pycontribs/ubuntu sleep 65000000
```

```
vagrant@dev-ansible:~/devops-netology-tests/ansible/81$ sudo service docker start
vagrant@dev-ansible:~/devops-netology-tests/ansible/81$ sudo service docker status
```

#### 4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.

```
vagrant@dev-ansible:~/devops-netology-tests/ansible/81$ sudo ansible-playbook -i inventory/prod.yml -v site.yml
Using /etc/ansible/ansible.cfg as config file

PLAY [Print os facts] ******************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] **********************************************************************************************************
ok: [centos7] => {
    "msg": "el"
}
ok: [ubuntu] => {
    "msg": "deb"
}

PLAY RECAP *****************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

#### 5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.

```
$ cat group_vars/deb/examp.yml 
---
  some_fact: "deb default fact"

$ cat group_vars/el/examp.yml 
---
  some_fact: "el default fact"
```

#### 6. Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.

```
vagrant@dev-ansible:~/devops-netology-tests/ansible/81$ sudo ansible-playbook -i inventory/prod.yml -v site.yml
Using /etc/ansible/ansible.cfg as config file

PLAY [Print os facts] ******************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] **********************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP *****************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

#### 7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.

```
vagrant@dev-ansible:~/devops-netology-tests/ansible/81$ ansible-vault encrypt group_vars/deb/examp.yml
New Vault password: 
Confirm New Vault password: 
Encryption successful
vagrant@dev-ansible:~/devops-netology-tests/ansible/81$ ansible-vault encrypt group_vars/el/examp.yml
New Vault password: 
Confirm New Vault password: 
Encryption successful
```

#### 8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.

```
vagrant@dev-ansible:~/devops-netology-tests/ansible/81$ sudo ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
Vault password:

PLAY [Print os facts] ******************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] **********************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP *****************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```


#### 9.  Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.

ansible-doc -t connection -l
-> local

#### 10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.

```
$ cat inventory/prod.yml 
---
  el:
    hosts:
      centos7:
        ansible_connection: docker
  deb:
    hosts:
      ubuntu:
        ansible_connection: docker
  local:
    hosts:
      localhost:
        ansible_connection: local
```

#### 11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.

```
vagrant@dev-ansible:~/devops-netology-tests/ansible/81$ sudo ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pas
s
Vault password:

PLAY [Print os facts] ******************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************
ok: [localhost]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] **********************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [localhost] => {
    "msg": "all default fact"
}

PLAY RECAP *****************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

При добавлении group_vars для local, получаем local default fact 

```
vagrant@dev-ansible:~/devops-netology-tests/ansible/81$ sudo ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
Vault password:

PLAY [Print os facts] ******************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************
ok: [localhost]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] **********************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [localhost] => {
    "msg": "local default fact"
}

PLAY RECAP *****************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

#### 12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.

https://github.com/skurudo/devops-netology-tests/tree/master/ansible/81

```
### Самоконтроль выполненения задания

#### 1. Где расположен файл с `some_fact` из второго пункта задания?

playbook/group_vars/all/examp.yml

#### 2. Какая команда нужна для запуска вашего `playbook` на окружении `test.yml`?

$ ansible-playbook site.yml -i inventory/test.yml

#### 3. Какой командой можно зашифровать файл?

$ ansible-vault encrypt group_vars/deb/examp.yml

#### 4. Какой командой можно расшифровать файл?

$ ansible-vault decrypt group_vars/deb/examp.yml

#### 5. Можно ли посмотреть содержимое зашифрованного файла без команды расшифровки файла? Если можно, то как?

$ ansible-vault view group_vars/deb/examp.yml

#### 6. Как выглядит команда запуска `playbook`, если переменные зашифрованы?

$ ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass

#### 7. Как называется модуль подключения к host на windows?

ansible_connection: winrm

#### 8. Приведите полный текст команды для поиска информации в документации ansible для модуля подключений ssh

ansible-doc -t connection ssh

#### 9. Какой параметр из модуля подключения `ssh` необходим для того, чтобы определить пользователя, под которым необходимо совершать подключение?

remote_user
```