# Домашнее задание к занятию "5.2. Применение принципов IaaC в работе с виртуальными машинами"

---

## Задача 1

> - Опишите своими словами основные преимущества применения на практике IaaC паттернов.
> - Какой из принципов IaaC является основополагающим?

### Ответ на задачу 1
> - Опишите своими словами основные преимущества применения на практике IaaC паттернов.

Цена, скорость и уменьшение рисков.
Уменьшаем расходы, автоматизируя. Повышаем скорость выката релизов, опять же исходя из повторяемости результатов и автоматизации процессов. Уменьшаем риски падений за счет тестирования и автоматизации.

> - Какой из принципов IaaC является основополагающим?

Идемпотентность, повторяемость результатов операции

## Задача 2
> - Чем Ansible выгодно отличается от других систем управление конфигурациями?
> - Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?

### Ответ на задачу 2

> - Чем Ansible выгодно отличается от других систем управление конфигурациями?

Агенты не нужны - доступ по ssh достаточен. Написан на питоне, комьюнити, документация. Используется метод push (морально ближе)

> - Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?

Мне больше импонирует push или гибридный метод. Не смотря на то, что при обновлении сетевого оборудования чаще всего использую гибридный подход, но обновление из управляющего сервера видится мне более надёжным.

## Задача 3

> Установить на личный компьютер:
> - VirtualBox
> - Vagrant
> - Ansible
> *Приложить вывод команд установленных версий каждой из программ, оформленный в markdown.*

### Ответ на задачу 3
> - VirtualBox

снесли VMVare, поставили VirtualBox 6.1.32 

> - Vagrant

PS C:\Users\skuru\vagrant> vagrant -v
Vagrant 2.2.19

```
PS C:\Users\skuru\vagrant> vagrant box add bento/ubuntu-20.04 --provider=virtualbox --force
==> box: Loading metadata for box 'bento/ubuntu-20.04'
    box: URL: https://vagrantcloud.com/bento/ubuntu-20.04
==> box: Adding box 'bento/ubuntu-20.04' (v202112.19.0) for provider: virtualbox
    box: Downloading: https://vagrantcloud.com/bento/boxes/ubuntu-20.04/versions/202112.19.0/providers/virtualbox.box
    box:
==> box: Successfully added box 'bento/ubuntu-20.04' (v202112.19.0) for 'virtualbox'!
PS C:\Users\skuru\vagrant> vagrant box list
bento/ubuntu-20.04 (virtualbox, 202112.19.0)
```

> - Ansible

Поставили внутри виртуалки... использовали частично для развертки элементы из лекции
```
vagrant@server1:~$ ansible --version
ansible 2.9.6
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/vagrant/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.8.10 (default, Mar 15 2022, 12:22:08) [GCC 9.4.0]
 ```
Развернулось вот такое:
```
vagrant@server1:~$ cat /etc/lsb-release
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=20.04
DISTRIB_CODENAME=focal
DISTRIB_DESCRIPTION="Ubuntu 20.04.3 LTS"

vagrant@server1:~$ ip a | grep inet | grep 192
    inet 192.168.192.11/24 brd 192.168.192.255 scope global eth1

vagrant@server1:~$ hostname -f
server1.netology

vagrant@server1:~$ free
              total        used        free      shared  buff/cache   available
Mem:        1004800      128836      299748         964      576216      724300
Swap:       2009084           0     2009084
``` 

Но все еще грустно... добавили реп
```
$ sudo apt-add-repository ppa:ansible/ansible
```

Обновились и получили такое:
```
vagrant@server1:~$ ansible --version
ansible [core 2.12.4]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/vagrant/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /home/vagrant/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.8.10 (default, Mar 15 2022, 12:22:08) [GCC 9.4.0]
  jinja version = 2.10.1
  libyaml = True
```

## Задача 4 (*)

> Воспроизвести практическую часть лекции самостоятельно.
> - Создать виртуальную машину.
> - Зайти внутрь ВМ, убедиться, что Docker установлен с помощью команды
> ```
> docker ps
> ```

### Ответ на задачу 4
Оказалось, что все не так просто под Windows... Сложностей пара вагончиков - ансибля для окошек как бы нет - Windows is not officially supported for the Ansible Control Machine.. ansible не запускается - пересмотрел статей через запуск через CYGWIN и Choko... Столько времени, боли и унижений не было давно и все при около нулевом результате. Не утверждаю, что нереально, но за достаточное время победы не вышло. Связка по запуску ansible через cgywin провалилась

Эксперимент с вагрантом в среде, где можно было попробовать что-то не критичное тоже завершился неудачно. Вагрант блокирует РФ.. пришлось изобретать велосипед с велосипедом. Делать виртуалку на том, что было и внутри виртуалки делать виртуалки... эта великолепная идея, впрочем тоже потерпела фиаско. Ошибки виртуалбокса с сеть и необычные были великолепны:

```==> srvr1.netology: Importing base box 'bento/ubuntu-20.04'...
Progress: 90%There was an error while executing `VBoxManage`, a CLI used by Vagrant
for controlling VirtualBox. The command and stderr is shown below.

Command: ["import", "/home/sku/.vagrant.d/boxes/bento-VAGRANTSLASH-ubuntu-20.04/202112.19.0/virtualbox/box.ovf", "--vsys", "0", "--vmname", "ubuntu-20.04-amd64_1650281754567_32511", "--vsys", "0", "--unit", "11", "--disk", "/home/sku/VirtualBox VMs/ubuntu-20.04-amd64_1650281754567_32511/ubuntu-20.04-amd64-disk001.vmdk"]

Stderr: 0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
Interpreting /home/sku/.vagrant.d/boxes/bento-VAGRANTSLASH-ubuntu-20.04/202112.19.0/virtualbox/box.ovf...
OK.
0%...10%...
Progress state: NS_ERROR_INVALID_ARG
VBoxManage: error: Appliance import failed
VBoxManage: error: Code NS_ERROR_INVALID_ARG (0x80070057) - Invalid argument value (extended info not available)
VBoxManage: error: Context: "RTEXITCODE handleImportAppliance(HandlerArg*)" at line 1119 of file VBoxManageAppliance.cpp
```

Ну и конечно не поднимающаяся сеть...
```
There was an error while executing `VBoxManage`, a CLI used by Vagrant
for controlling VirtualBox. The command and stderr is shown below.

Command: ["hostonlyif", "ipconfig", "vboxnet5", "--ip", "192.168.194.1", "--netmask", "255.255.255.0"]

Stderr: VBoxManage: error: Code E_ACCESSDENIED (0x80070005) - Access denied (extended info not available)
VBoxManage: error: Context: "EnableStaticIPConfig(Bstr(pszIp).raw(), Bstr(pszNetmask).raw())" at line 242 of file VBoxManageHostonly.cpp
```

Прикинув альтернативы посмотрел в сторону LXC и получилось немного лучше... но как немного? Снова пришлось повозиться и слегка изменять Vagrantfile и плейбук.. но мы хотя бы продвинулись дальше. На 21.10 c LXC получили некоторое количество проблем со стартом контейнера и vagrant.. В основном проблема была с сетью или долгим запуском, вагрант отваливался по таймапуту. Успешный старт был с fgrehm/precise64-lxc - в итоге почти весь плейбук отыграли... но уперлись в то, что precise = 12.04 и докер там уже EOL (по крайней мере не идет от стандартного инсталлятора).

Рабочее окружение у нас получилось вот такое:
```
$ cat /etc/lsb-release
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=21.10
DISTRIB_CODENAME=impish
DISTRIB_DESCRIPTION="Ubuntu 21.10"

$ lxc version
Client version: 5.0.0
Server version: 5.0.0

$ ansible --version
ansible 2.10.8
  config file = None
  configured module search path = ['/home/sku/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.9.7 (default, Sep 10 2021, 14:59:43) [GCC 11.2.0]

$ vagrant --version
Vagrant 2.2.14
```

Перепробовав убунту старше 12-ой.. внезапно мы сталкиваемся с проблемой по установке докера уже в Debian 9.. и снова узнаем о том, что  This Linux distribution reached end-of-life and is no longer supported by this script.

```
sku@udev:~/dev$ vagrant reload --provision
==> project: Attempting graceful shutdown of VM...
==> project: Checking if box 'debian/stretch64' version '9.1.0' is up to date...
==> project: Setting up mount entries for shared folders...
    project: /vagrant => /home/sku/dev
==> project: Starting container...
==> project: Waiting for machine to boot. This may take a few minutes...
    project: SSH address: 10.0.3.249:22
    project: SSH username: vagrant
    project: SSH auth method: private key
==> project: Machine booted and ready!
==> project: Running provisioner: ansible...
    project: Running ansible-playbook...
PYTHONUNBUFFERED=1 ANSIBLE_FORCE_COLOR=true ANSIBLE_HOST_KEY_CHECKING=false ANSIBLE_SSH_ARGS='-o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes -o ControlMaster=auto -o ControlPersist=60s' ansible-playbook --connection=ssh --timeout=30 --limit="project" --inventory-file=/home/sku/dev/.vagrant/provisioners/ansible/inventory -vv /home/sku/ansible/provision.yml
ansible-playbook 2.10.8
  config file = None
  configured module search path = ['/home/sku/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible-playbook
  python version = 3.9.7 (default, Sep 10 2021, 14:59:43) [GCC 11.2.0]
No config file found; using defaults
Skipping callback 'default', as we already have a stdout callback.
Skipping callback 'minimal', as we already have a stdout callback.
Skipping callback 'oneline', as we already have a stdout callback.

PLAYBOOK: provision.yml ********************************************************
1 plays in /home/sku/ansible/provision.yml

PLAY [all] *********************************************************************

TASK [Gathering Facts] *********************************************************
task path: /home/sku/ansible/provision.yml:2
[DEPRECATION WARNING]: Distribution debian 9.1 on host project should use
/usr/bin/python3, but is using /usr/bin/python for backward compatibility with
prior Ansible releases. A future Ansible release will default to using the
discovered platform python for this host. See https://docs.ansible.com/ansible/
2.10/reference_appendices/interpreter_discovery.html for more information. This
 feature will be removed in version 2.12. Deprecation warnings can be disabled
by setting deprecation_warnings=False in ansible.cfg.
ok: [project]
META: ran handlers

TASK [Create directory for ssh-keys] *******************************************
task path: /home/sku/ansible/provision.yml:8
ok: [project] => {"changed": false, "gid": 0, "group": "root", "mode": "0700", "owner": "root", "path": "/root/.ssh/", "size": 4096, "state": "directory", "uid": 0}

TASK [Adding rsa-key in /root/.ssh/authorized_keys] ****************************
task path: /home/sku/ansible/provision.yml:11
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: If you are using a module and expect the file to exist on the remote, see the remote_src option
fatal: [project]: FAILED! => {"changed": false, "msg": "Could not find or access '~/.ssh/id_rsa.pub' on the Ansible Controller.\nIf you are using a module and expect the file to exist on the remote, see the remote_src option"}
...ignoring

TASK [Installing tools] ********************************************************
task path: /home/sku/ansible/provision.yml:15
ok: [project] => (item=git) => {"ansible_loop_var": "item", "cache_update_time": 1650290542, "cache_updated": false, "changed": false, "item": "git"}
ok: [project] => (item=curl) => {"ansible_loop_var": "item", "cache_update_time": 1650290542, "cache_updated": false, "changed": false, "item": "curl"}
ok: [project] => (item=dnsutils) => {"ansible_loop_var": "item", "cache_update_time": 1650290542, "cache_updated": false, "changed": false, "item": "dnsutils"}

TASK [Checking DNS] ************************************************************
task path: /home/sku/ansible/provision.yml:23
changed: [project] => {"changed": true, "cmd": ["host", "-t", "A", "google.com"], "delta": "0:00:00.007608", "end": "2022-04-18 14:03:15.085988", "rc": 0, "start": "2022-04-18 14:03:15.078380", "stderr": "", "stderr_lines": [], "stdout": "google.com has address 173.194.220.102\ngoogle.com has address 173.194.220.113\ngoogle.com has address 173.194.220.100\ngoogle.com has address 173.194.220.139\ngoogle.com has address 173.194.220.138\ngoogle.com has address 173.194.220.101", "stdout_lines": ["google.com has address 173.194.220.102", "google.com has address 173.194.220.113", "google.com has address 173.194.220.100", "google.com has address 173.194.220.139", "google.com has address 173.194.220.138", "google.com has address 173.194.220.101"]}

TASK [Installing docker] *******************************************************
task path: /home/sku/ansible/provision.yml:26
fatal: [project]: FAILED! => {"changed": true, "cmd": "curl -fsSL get.docker.com -o get-docker.sh && chmod +x get-docker.sh && ./get-docker.sh", "delta": "0:00:11.983554", "end": "2022-04-18 14:03:27.210269", "msg": "non-zero return code", "rc": 100, "start": "2022-04-18 14:03:15.226715", "stderr": "+ sh -c apt-get update -qq >/dev/null\n+ sh -c DEBIAN_FRONTEND=noninteractive apt-get install -y -qq apt-transport-https ca-certificates curl >/dev/null\n+ sh -c curl -fsSL \"https://download.docker.com/linux/debian/gpg\" | gpg --dearmor --yes -o /usr/share/keyrings/docker-archive-keyring.gpg\n+ sh -c echo \"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian stretch stable\" > /etc/apt/sources.list.d/docker.list\n+ sh -c apt-get update -qq >/dev/null\n+ sh -c DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends  docker-ce-cli docker-scan-plugin docker-ce >/dev/null\nE: Unable to locate package docker-scan-plugin", "stderr_lines": ["+ sh -c apt-get update -qq >/dev/null", "+ sh -c DEBIAN_FRONTEND=noninteractive apt-get install -y -qq apt-transport-https ca-certificates curl >/dev/null", "+ sh -c curl -fsSL \"https://download.docker.com/linux/debian/gpg\" | gpg --dearmor --yes -o /usr/share/keyrings/docker-archive-keyring.gpg", "+ sh -c echo \"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian stretch stable\" > /etc/apt/sources.list.d/docker.list", "+ sh -c apt-get update -qq >/dev/null", "+ sh -c DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends  docker-ce-cli docker-scan-plugin docker-ce >/dev/null", "E: Unable to locate package docker-scan-plugin"], "stdout": "# Executing docker install script, commit: 93d2499759296ac1f9c510605fef85052a2c32be\n\n\u001b[91;1mDEPRECATION WARNING\u001b[0m\n    This Linux distribution (\u001b[1mdebian stretch\u001b[0m) reached end-of-life and is no longer supported by this script.\n    No updates or security fixes will be released for this distribution, and users are recommended\n    to upgrade to a currently maintained version of debian.\n\nPress \u001b[1mCtrl+C\u001b[0m now to abort this script, or wait for the installation to continue.", "stdout_lines": ["# Executing docker install script, commit: 93d2499759296ac1f9c510605fef85052a2c32be", "", "\u001b[91;1mDEPRECATION WARNING\u001b[0m", "    This Linux distribution (\u001b[1mdebian stretch\u001b[0m) reached end-of-life and is no longer supported by this script.", "    No updates or security fixes will be released for this distribution, and users are recommended", "    to upgrade to a currently maintained version of debian.", "", "Press \u001b[1mCtrl+C\u001b[0m now to abort this script, or wait for the installation to continue."]}
[WARNING]: Consider using the get_url or uri module rather than running 'curl'.
If you need to use command because get_url or uri is insufficient you can add
'warn: false' to this command task or set 'command_warnings=False' in
ansible.cfg to get rid of this message.

PLAY RECAP *********************************************************************
project                    : ok=5    changed=1    unreachable=0    failed=1    skipped=0    rescued=0    ignored=1
```

Попытки слегка собрать докер командой тоже не особо удались, свалились в ошибку:

```
    - name: "Installing docker"
      shell: git clone https://github.com/jmtd/debian-docker.git && cd debian-docker/ && sudo make release=stretch prefix=jmtd arch=amd64 mirror=http://httpredir.debian.org/debian/
```

В итоге пришлось сделать то, что как раз и не рекомендовалось в ходе лекции - установить docker из реп.. :(

И немедленно прийти к мысли, что нужна какая-то более стабильная среда для тестирования ansible и использования нескольких vagrant'ов. А связка с вагрантом неплохая, но сильно зависит от типа используемых виртуальных машин. Т.е. универсальности не наблюдается. Кроме VirtualBox толком нормально не работает, что-то сложное и уже не так работает. Также для себя сделал вывод, что LXC в связке с vagrant использовать не стоит, готовые образы в основном все старые или EOL :(

```
PLAY RECAP *********************************************************************
project                    : ok=6    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=1
```

> ```
> docker ps
> ```

```
vagrant@stretch:~$  docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

---

### То до чего в итоге были порезы конфигураций :(

/home/sku/dev/Vagrantfile 
```
Vagrant.configure("2") do |config|
  config.vm.box = "debian/stretch64"
  config.vm.define "project" do |project|
    project.vm.provider "lxc" do |lxc|
      lxc.backingstore = 'none'
    end
    project.vm.provision :ansible do |ansible|
      ansible.playbook = "/home/sku/ansible/provision.yml"
      inventory_path = "/home/sku/ansible/inventory"
      ansible.verbose = 'vv'
    end
  end
end
```

/home/sku/ansible/provision.yml 
```
---
- hosts: all
  become: yes
  become_user: root
  remote_user: vagrant

  tasks:
    - name: "Create directory for ssh-keys"
      file: state=directory mode=0700 dest=~/.ssh/

    - name: "Adding rsa-key in /root/.ssh/authorized_keys"
      copy: src=~/.ssh/id_rsa.pub dest=~/.ssh/authorized_keys owner=root mode=0600
      ignore_errors: yes

    - name: "Installing tools"
      apt:
        name: "{{ item }}"
      loop:
        - git
        - curl
        - dnsutils
        - make
        - docker-ce

    - name: "Checking DNS"
      command: host -t A google.com

    - name: "Add the current user to docker group"
      user: name=vagrant append=yes groups=docker
```