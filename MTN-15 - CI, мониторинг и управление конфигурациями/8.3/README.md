# Домашнее задание к занятию "08.03 Использование Yandex Cloud"

## Подготовка к выполнению

1. Подготовьте в Yandex Cloud три хоста: для `clickhouse`, для `vector` и для `lighthouse`.
Ссылка на репозиторий LightHouse: https://github.com/VKCOM/lighthouse

Подготовили

```
vagrant@dev-ansible:~/devops-netology-tests/ansible/83$ ansible-playbook -i inventory/prod.yml upgrade_reboot.yml

PLAY [Upgrade and Reboot RHEL & Debian family Linux distros] ******************************************************************

TASK [Gathering Facts] ********************************************************************************************************
ok: [clickhouse-02]
ok: [clickhouse-01]
ok: [clickhouse-03]

TASK [Upgrade RHEL Family OS packages] ****************************************************************************************
ok: [clickhouse-03]
ok: [clickhouse-02]
ok: [clickhouse-01]

TASK [Update repositories cache] **********************************************************************************************
skipping: [clickhouse-01]
skipping: [clickhouse-02]
skipping: [clickhouse-03]

TASK [Update all packages to their latest version] ****************************************************************************
skipping: [clickhouse-01]
skipping: [clickhouse-02]
skipping: [clickhouse-03]

TASK [Upgrade the OS (apt-get dist-upgrade)] **********************************************************************************
skipping: [clickhouse-01]
skipping: [clickhouse-02]
skipping: [clickhouse-03]

TASK [Reboot host] ************************************************************************************************************
changed: [clickhouse-03]
changed: [clickhouse-01]
changed: [clickhouse-02]

PLAY RECAP ********************************************************************************************************************
clickhouse-01              : ok=3    changed=1    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
clickhouse-02              : ok=3    changed=1    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
clickhouse-03              : ok=3    changed=1    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
```

## Основная часть

1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает lighthouse.
2. При создании tasks рекомендую использовать модули: `get_url`, `template`, `yum`, `apt`.
3. Tasks должны: скачать статику lighthouse, установить nginx или любой другой webserver, настроить его конфиг для открытия lighthouse, запустить webserver.

```
---
- name: Install Clickhouse
  hosts: clickhouse
  become: true
  handlers:
    - name: Start clickhouse service
      ansible.builtin.service:
        name: clickhouse-server
        state: restarted
  tasks:
    - block:
        - name: Get clickhouse distrib
          ansible.builtin.get_url:
            url: "https://packages.clickhouse.com/rpm/stable/{{ item }}-{{ clickhouse_version }}.x86_64.rpm"
            dest: "./{{ item }}-{{ clickhouse_version }}.rpm"
            mode: 0755
          with_items: "{{ clickhouse_packages }}"
    - name: Install clickhouse packages
      ansible.builtin.yum:
        name:
          - clickhouse-common-static-{{ clickhouse_version }}.rpm
          - clickhouse-client-{{ clickhouse_version }}.rpm
          - clickhouse-server-{{ clickhouse_version }}.rpm
      notify: Start clickhouse service
    - name: Flush handlers
      ansible.builtin.meta: flush_handlers
    - name: Delay 5 sec
      ansible.builtin.wait_for:
        timeout: 5
    - name: Create database
      ansible.builtin.command: "clickhouse-client -q 'create database logs;'"
      register: create_db
      failed_when: create_db.rc != 0 and create_db.rc !=82
      changed_when: create_db.rc == 0

- name: Install Vector
  hosts: vector
  handlers:
    - name: Start Vector service
      become: true
      ansible.builtin.service:
        name: vector
        state: restarted

  tasks:
- name: Install Vector
  hosts: vector
  tasks:
    - name: VECTOR | Install rpm
      become: true
      ansible.builtin.yum:
        name: "{{ vector_url }}"
        state: present
    - name: VECTOR | Template config
      become: true
      ansible.builtin.template:
        src: templates/vector.yml.j2
        dest: /etc/vector/vector.yml
        mode: "0644"
        owner: "{{ ansible_user_id }}"
        group: "{{ ansible_user_gid }}"
        validate: vector validate --no-environment --config-yaml %s
    - name: VECTOR | Create systemd unit
      become: true
      ansible.builtin.template:
        src: templates/vector.service.j2
        dest: /etc/systemd/system/vector.service
        mode: "0644"
        owner: "{{ ansible_user_id }}"
        group: "{{ ansible_user_gid }}"
    - name: VECTOR | Start service
      become: true
      ansible.builtin.systemd:
        name: vector
        state: started
        daemon_reload: true

- name: Install Nginx
  hosts: lighthouse
  become: true
  handlers:
    - name: Start nginx service
      become: true
      ansible.builtin.service:
        name: nginx
        state: restarted
  tasks:
    - name: Install epel-release
      yum:
        name: epel-release
        state: present
    - name: Install Nginx
      become: true
      yum:
        name: nginx
        state: present
      notify: Start nginx service
    - name: Create dir for Lighthouse
      become: true
      file:
        path: "{{ lighthouse_location_dir }}"
        state: directory
    - name: Create Nginx config
      become: true
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/nginx.conf
        mode: 0644
      notify: Start nginx service

- name: Install lighthouse
  hosts: lighthouse
  handlers:
    - name: Reload nginx service
      become: true
      command: nginx -s reload
  pre_tasks:
    - name: Install git
      become: true
      yum:
        name: git
        state: present
  tasks:
    - name: Copy lighthouse from git
      git:
        repo: "{{ lighthouse_vcs }}"
        version: master
        dest: "{{ lighthouse_location_dir }}"
      become: true
    - name: Create lighthouse config
      become: true
      template:
        src: lighthouse.conf.j2
        dest: /etc/nginx/conf.d/default.conf
        mode: 0644
      notify: Reload nginx service
  post_tasks:
    - name: Show connect URL lighthouse
      debug:
        msg: "http://{{ ansible_host }}/#http://{{ hostvars['clickhouse-01'].ansible_host }}:8123/?user={{ clickhouse_user }}"
```

4. Приготовьте свой собственный inventory файл `prod.yml`.

```
---
clickhouse:
  hosts:
    clickhouse-01:
      ansible_host: 158.160.9.66
      ansible_ssh_user: vagrant

vector:
  hosts:
    clickhouse-02:
      ansible_host: 158.160.9.186
      ansible_ssh_user: vagrant

lighthous:
  hosts:
    clickhouse-03:
      ansible_host: 84.252.140.216
      ansible_ssh_user: vagrant
```


5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.

Отработал без ошибок

```
$ ansible-lint site.yml
```

6. Попробуйте запустить playbook на этом окружении с флагом `--check`.

```
ansible-playbook site.yml -i inventory/prod.yml --check
```

```
vagrant@dev-ansible:~/devops-netology-tests/ansible/83$ ansible-playbook site.yml -i inventory/prod.yml --check

PLAY [Install Clickhouse] *****************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] *************************************************************************************************
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
changed: [clickhouse-01] => (item=clickhouse-common-static)

TASK [Install clickhouse packages] ********************************************************************************************
fatal: [clickhouse-01]: FAILED! => {"changed": false, "msg": "No RPM file matching 'clickhouse-common-static-22.3.9.19.rpm' found on system", "rc": 127, "results": ["No RPM file matching 'clickhouse-common-static-22.3.9.19.rpm' found on system"]}

PLAY RECAP ********************************************************************************************************************
clickhouse-01              : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0
```

```
vagrant@dev-ansible:~/devops-netology-tests/ansible/83$ ansible-playbook site.yml -i inventory/prod.yml --check

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
skipping: [clickhouse-01]

TASK [Create database] ********************************************************************************************************
skipping: [clickhouse-01]

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

PLAY [Install Nginx] **********************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************
ok: [clickhouse-03]

TASK [Install epel-release] ***************************************************************************************************
ok: [clickhouse-03]

TASK [Install Nginx] **********************************************************************************************************
ok: [clickhouse-03]

TASK [Create dir for Lighthouse] **********************************************************************************************
changed: [clickhouse-03]

TASK [Create Nginx config] ****************************************************************************************************
ok: [clickhouse-03]

PLAY [Install lighthouse] *****************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************
ok: [clickhouse-03]

TASK [Install git] ************************************************************************************************************
ok: [clickhouse-03]

TASK [Copy lighthouse rfom git] ***********************************************************************************************
changed: [clickhouse-03]

TASK [Create lighthouse config] ***********************************************************************************************
changed: [clickhouse-03]

RUNNING HANDLER [Reload nginx service] ****************************************************************************************
skipping: [clickhouse-03]

TASK [Show connect URL lighthouse] ********************************************************************************************
ok: [clickhouse-03] => {
    "msg": "http://84.252.140.216/#http://158.160.9.66:8123/?user=netology"
}

PLAY RECAP ********************************************************************************************************************
clickhouse-01              : ok=3    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
clickhouse-02              : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
clickhouse-03              : ok=10   changed=3    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

```


7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.

```
ansible-playbook site.yml -i inventory/prod.yml --diff
```

```
vagrant@dev-ansible:~/devops-netology-tests/ansible/83$ ansible-playbook site.yml -i inventory/prod.yml --diff

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

PLAY [Install Nginx] **********************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************
ok: [clickhouse-03]

TASK [Install epel-release] ***************************************************************************************************
ok: [clickhouse-03]

TASK [Install Nginx] **********************************************************************************************************
ok: [clickhouse-03]

TASK [Create dir for Lighthouse] **********************************************************************************************
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/home/vagrant/lighthouse",
-    "state": "absent"
+    "state": "directory"
 }

changed: [clickhouse-03]

TASK [Create Nginx config] ****************************************************************************************************
ok: [clickhouse-03]

PLAY [Install lighthouse] *****************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************
ok: [clickhouse-03]

TASK [Install git] ************************************************************************************************************
ok: [clickhouse-03]

TASK [Copy lighthouse from git] ***********************************************************************************************
>> Newly checked out d701335c25cd1bb9b5155711190bad8ab852c2ce
changed: [clickhouse-03]

TASK [Create lighthouse config] ***********************************************************************************************
--- before
+++ after: /home/vagrant/.ansible/tmp/ansible-local-9285t8fwydd0/tmp72ok152n/lighthouse.conf.j2
@@ -0,0 +1,11 @@
+server {
+    listen       80;
+    server_name  localhost
+
+    access_log  /var/log/nginx lighthouse_access.log  main;
+
+    location / {
+        root   /home/vagrant/lighthouse;
+        index  index.html;
+    }
+}

changed: [clickhouse-03]

RUNNING HANDLER [Reload nginx service] ****************************************************************************************
changed: [clickhouse-03]

TASK [Show connect URL lighthouse] ********************************************************************************************
ok: [clickhouse-03] => {
    "msg": "http://84.252.140.216/#http://158.160.9.66:8123/?user=netology"
}

PLAY RECAP ********************************************************************************************************************
clickhouse-01              : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
clickhouse-02              : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
clickhouse-03              : ok=11   changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.


```
ansible-playbook site.yml -i inventory/prod.yml --diff
```

```
vagrant@dev-ansible:~/devops-netology-tests/ansible/83$ ansible-playbook site.yml -i inventory/prod.yml --diff

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

PLAY [Install Nginx] **********************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************
ok: [clickhouse-03]

TASK [Install epel-release] ***************************************************************************************************
ok: [clickhouse-03]

TASK [Install Nginx] **********************************************************************************************************
ok: [clickhouse-03]

TASK [Create dir for Lighthouse] **********************************************************************************************
ok: [clickhouse-03]

TASK [Create Nginx config] ****************************************************************************************************
ok: [clickhouse-03]

PLAY [Install lighthouse] *****************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************
ok: [clickhouse-03]

TASK [Install git] ************************************************************************************************************
ok: [clickhouse-03]

TASK [Copy lighthouse from git] ***********************************************************************************************
ok: [clickhouse-03]

TASK [Create lighthouse config] ***********************************************************************************************
ok: [clickhouse-03]

TASK [Show connect URL lighthouse] ********************************************************************************************
ok: [clickhouse-03] => {
    "msg": "http://84.252.140.216/#http://158.160.9.66:8123/?user=netology"
}

PLAY RECAP ********************************************************************************************************************
clickhouse-01              : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
clickhouse-02              : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
clickhouse-03              : ok=10   changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

9.  Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.

done

https://github.com/skurudo/devops-netology-tests/blob/08-ansible-03-yandex-v3/ansible/83/README.md

10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-03-yandex` на фиксирующий коммит, в ответ предоставьте ссылку на него.

```
git add .
git push origin master
git tag -a 08-ansible-03-yandex-v3
git push origin 08-ansible-03-yandex-v3

```

https://github.com/skurudo/devops-netology-tests/tree/08-ansible-03-yandex-v3