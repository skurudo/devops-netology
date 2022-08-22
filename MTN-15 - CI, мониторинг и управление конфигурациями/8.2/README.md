# Домашнее задание к занятию "08.02 Работа с Playbook"

## Подготовка к выполнению

#### 1. (Необязательно) Изучите, что такое [clickhouse](https://www.youtube.com/watch?v=fjTNS2zkeBs) и [vector](https://www.youtube.com/watch?v=CgEhyffisLY)

done
Но видео короткие, мы привыкли уже, что с Алексеем все становится длиннее :)))

#### 2. Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.

https://github.com/skurudo/devops-netology-tests/tree/master/ansible/82

#### 3. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.

done

#### 4. Подготовьте хосты в соответствии с группами из предподготовленного playbook.

done

## Основная часть

#### 1. Приготовьте свой собственный inventory файл `prod.yml`.

```
---
clickhouse:
  hosts:
    clickhouse-01:
      ansible_host: 84.201.154.122
      ansible_ssh_user: vagrant

vector:
  hosts:
    clickhouse-02:
      ansible_host: 84.252.141.147
      ansible_ssh_user: vagrant
```

#### 2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev).
#### 3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
#### 4. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, установить vector.

#### 5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.

Сначала нужно доустановить
```
vagrant@dev-ansible:~/devops-netology-tests$ sudo apt-get install ansible-lint

vagrant@dev-ansible:~/devops-netology-tests$ ansible-lint ansible/82/site.yml
```

```
vagrant@dev-ansible:~/devops-netology-tests$ ansible-lint ansible/82/site.yml
[204] Lines should be no longer than 160 chars
ansible/82/site.yml:98

vagrant@dev-ansible:~/devops-netology-tests$ ansible-lint site.yml
ошибки не фиксируем

```
#### 6. Попробуйте запустить playbook на этом окружении с флагом `--check`.

```
vagrant@dev-ansible:~/devops-netology-tests/ansible/82$ ansible-playbook site.yml -i inventory/prod.yml --check

PLAY [Install Clickhouse] *****************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] *************************************************************************************************
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
changed: [clickhouse-01] => (item=clickhouse-common-static)

TASK [Install clickhouse packages] ********************************************************************************************
fatal: [clickhouse-01]: FAILED! => {"changed": false, "msg": "No RPM file matching 'clickhouse-common-static-22.7.3.5.rpm' found on system", "rc": 127, "results": ["No RPM file matching 'clickhouse-common-static-22.7.3.5.rpm' found on system"]}

PLAY RECAP ********************************************************************************************************************
clickhouse-01              : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0
```

#### 7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.

```
vagrant@dev-ansible:~/devops-netology-tests/ansible/82$ ansible-playbook site.yml -i inventory/prod.yml --diff

PLAY [Install Clickhouse] *****************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] *************************************************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
ok: [clickhouse-01] => (item=clickhouse-common-static)

TASK [Install clickhouse packages] ********************************************************************************************
ok: [clickhouse-01]

TASK [Flush handlers] *********************************************************************************************************

TASK [Delay 5 sec] ************************************************************************************************************
Pausing for 5 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
ok: [clickhouse-01]

TASK [Create database] ********************************************************************************************************
ok: [clickhouse-01]

PLAY [Install Vector] *********************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************
ok: [clickhouse-02]

PLAY [Install Vector] *********************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************
ok: [clickhouse-02]

TASK [VECTOR | Install rpm] ***************************************************************************************************
ok: [clickhouse-02]

TASK [VECTOR | Template config] ***********************************************************************************************
--- before
+++ after: /home/vagrant/.ansible/tmp/ansible-local-11420655bx7s_/tmp0ftzw5x_/vector.yml.j2
@@ -0,0 +1,18 @@
+sinks:
+    to_clickhouse:
+        compression: gzip
+        database: logs
+        endpoint: http://10.129.0.6:8123
+        healthcheck: false
+        inputs:
+        - our_log
+        skip_unknown_fields: true
+        table: access_logs
+        type: clickhouse
+sources:
+    our_log:
+        ignore_older_secs: 600
+        include:
+        - /var/log/nginx/access.log
+        read_from: beginning
+        type: file

changed: [clickhouse-02]

TASK [VECTOR | Create systemd unit] *******************************************************************************************
--- before
+++ after: /home/vagrant/.ansible/tmp/ansible-local-11420655bx7s_/tmp80n_tyjc/vector.service.j2
@@ -0,0 +1,11 @@
+[Unit]
+Description=Vector service
+After=network.target
+Requires=network-online.target
+[Service]
+User=root
+Group=root
+ExecStart=/usr/bin/vector --config-yaml /etc/vector/vector.yml
+Restart=always
+[Install]
+WantedBy=multi-user.target

changed: [clickhouse-02]

TASK [VECTOR | Start service] *************************************************************************************************
changed: [clickhouse-02]

PLAY RECAP ********************************************************************************************************************
clickhouse-01              : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
clickhouse-02              : ok=6    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

#### 8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.

```
vagrant@dev-ansible:~/devops-netology-tests/ansible/82$ ansible-playbook site.yml -i inventory/prod.yml --diff

PLAY [Install Clickhouse] *****************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] *************************************************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
ok: [clickhouse-01] => (item=clickhouse-common-static)

TASK [Install clickhouse packages] ********************************************************************************************
ok: [clickhouse-01]

TASK [Flush handlers] *********************************************************************************************************

TASK [Delay 5 sec] ************************************************************************************************************
Pausing for 5 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
ok: [clickhouse-01]

TASK [Create database] ********************************************************************************************************
ok: [clickhouse-01]

PLAY [Install Vector] *********************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************
ok: [clickhouse-02]

PLAY [Install Vector] *********************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************
ok: [clickhouse-02]

TASK [VECTOR | Install rpm] ***************************************************************************************************
ok: [clickhouse-02]

TASK [VECTOR | Template config] ***********************************************************************************************
ok: [clickhouse-02]

TASK [VECTOR | Create systemd unit] *******************************************************************************************
ok: [clickhouse-02]

TASK [VECTOR | Start service] *************************************************************************************************
ok: [clickhouse-02]

PLAY RECAP ********************************************************************************************************************
clickhouse-01              : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
clickhouse-02              : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

#### 9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.

https://github.com/skurudo/devops-netology-tests/blob/master/ansible/82/README.md

#### 10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-02-playbook` на фиксирующий коммит, в ответ предоставьте ссылку на него.

https://github.com/skurudo/devops-netology-tests/releases/tag/08-ansible-02-playbook

```
vagrant@dev-ansible:~/devops-netology-tests$ git tag -a 08-ansible-02-playbook
vagrant@dev-ansible:~/devops-netology-tests$ git push origin 08-ansible-02-playbook
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Writing objects: 100% (1/1), 173 bytes | 173.00 KiB/s, done.
Total 1 (delta 0), reused 0 (delta 0)
To github.com:skurudo/devops-netology-tests.git
 * [new tag]         08-ansible-02-playbook -> 08-ansible-02-playbook
 ```

 ## Комментарии сенсея

 Есть несколько советов для “реальной работы” :

- "Задержка после рестарта сервера, что бы успел запустится. "
Вместо pause. Вы можете использовать модуль wait_for https://docs.ansible.com/ansible/latest/collections/ansible/builtin/wait_for_module.html . С его помощью не нужно “хардкодить” некое количество секунд. Вы просто пишите условие статуса сетевого порта, сервиса, файла и даже строки поиска в ответе.

- Вы используете “become: true” в каждом таске. В финтех организации(например крупный банк) есть смысл ограничивать become на уровне отдельных task, в вашем же случае become лучше задать один раз на уровне запуска play.

- Комментарии обычно пишут к той части кода, которая выполняет что-то, что требует явного пояснения. Нет ничего плохо в избыточном комментарии, но и хорошего тоже. Обычно ansible код самодостаточен в плане документации. Все что может вызывать вопросы - стоит описать в README.md