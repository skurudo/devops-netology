# �������� ������� � ������� "5.5. ����������� ��������� Docker ����������� �� ������� Docker Swarm"

## ������ 1

����� ��������� ������ �� ��������� �������:

- � ��� ������� ������� ������ �������� � Docker Swarm ��������: replication � global?
- ����� �������� ������ ������ ������������ � Docker Swarm ��������?
- ��� ����� Overlay Network?

### ����� �� ������ 1

``` - � ��� ������� ������� ������ �������� � Docker Swarm ��������: replication � global? ```

 � ������ global ���������� ��� ���������� ��������(�)��� �� ���� �����, � � ������ replication ����������� ���������� ������ ������������ ��� ����������(�.�. �� �����-�� ���� ����� �� ���� ����������� ����������). 
 
``` - ����� �������� ������ ������ ������������ � Docker Swarm ��������? ```

Raft

```
- �������� ������ �������� ��������������� - ����� ��� manager-���� ����� ���������� ������������� � ��������� ��������
- ��� ���������������� ������ ������ ���� �� ����� ��� manager-���.
- ���������� ��� ����������� ������ ���� ��������, �� ����� �� ����� 7 (������������ �� ������������ Docker).
- ����� manager-��� ���������� �����, ��� ������ ������������� ���������������.
- ����� ���������� keepalive-������ � �������� �������������� � �������� 150-300��. ���� ������ �� ������, ��������� �������� ������ ������ ������.
- ���� ������� ������, �������� ���������� ��� ������ �������������, ��� ������� ��������� �������������, 
�.�. ���� ��������� ��������� ��������� �����������, ���� ��� �������� ����������� ���. ���� ������� ������� �������,
�������� ����� �����������, ��� � �����-�� ����� �������� ������ ����������� ���.
```

![Raft: ����� ������ ������](https://habrastorage.org/r/w1560/files/584/dcc/4e8/584dcc4e857d4e0a999e487d2e0dbbbe.gif)

``` - ��� ����� Overlay Network? ```

���������� ���� (�� ����. Overlay Network) � ����� ������ ���������� ����, ����������� ������ ������ ����. ���� ���������� ���� ����� ���� ������� ���� ���������� �����������, ���� ����������, ��� �������� � �������� ���� ���������� ���� ��� ��������� ��������������� ��������� �� ���������� ����������.

� ����� ������ ���� ���� �� L2 VPN ���� ��� ����� docker ������� ����� �����.


## ������ 2

������� ��� ������ Docker Swarm ������� � ������.������
��� ��������� ������, ��� ���������� ������������ �������� �� ��������� (�������), � ������� �������:
```
docker node ls
```

### ����� �� ������ 2

������ ������ centos-7-base.json
```folder_id � token```

����� �������� packer ��������� build
```$ packer build centos-7-base.json```

�����������:
```Build 'yandex' finished after 4 minutes 41 seconds.
==> Wait completed after 4 minutes 41 seconds
==> Builds finished. The artifacts of successful builds are:
--> yandex: A disk image was created: centos-7-base (id: fd85b24m06e37c8l0p21) with family name centos```


��������� ����� (��� ������):
```yc iam service-account --folder-id b1gqpnr6ba58jcqk0264 list
yc iam key create --folder-name default --service-account-name default-sa --output key.json
yc config set service-account-key key.json
yc iam create-token```

���� � terraform - init

```vagrant@dev-docker:~/05-virt-05-docker-swarm/src/terraform$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/null...
- Finding latest version of hashicorp/local...
- Finding latest version of yandex-cloud/yandex...
- Installing hashicorp/null v3.1.1...
- Installed hashicorp/null v3.1.1 (unauthenticated)
- Installing hashicorp/local v2.2.3...
- Installed hashicorp/local v2.2.3 (unauthenticated)
- Installing yandex-cloud/yandex v0.76.0...
- Installed yandex-cloud/yandex v0.76.0 (unauthenticated)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.
Terraform has been successfully initialized!```

�����...

```vagrant@dev-docker:~/05-virt-05-docker-swarm/src/terraform$ terraform plan```

� �������...

```vagrant@dev-docker:~/05-virt-05-docker-swarm/src/terraform$ terraform apply```

���������:

```
Apply complete! Resources: 13 added, 0 changed, 0 destroyed.
Outputs:
external_ip_address_node01 = "51.250.88.199"
external_ip_address_node02 = "51.250.65.189"
external_ip_address_node03 = "51.250.82.3"
external_ip_address_node04 = "51.250.67.13"
external_ip_address_node05 = "51.250.81.183"
external_ip_address_node06 = "51.250.84.97"
internal_ip_address_node01 = "192.168.101.11"
internal_ip_address_node02 = "192.168.101.12"
internal_ip_address_node03 = "192.168.101.13"
internal_ip_address_node04 = "192.168.101.14"
internal_ip_address_node05 = "192.168.101.15"
internal_ip_address_node06 = "192.168.101.16"
```

�����������:
```
vagrant@dev-docker:~/05-virt-05-docker-swarm/src/terraform$ ssh centos@51.250.88.199
[centos@node01 ~]$ docker node ls
Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.24/nodes": dial unix /var/run/docker.sock: connect: permission denied
[centos@node01 ~]$ sudo docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
xyr7u8f0mvr24ycpztingw69v *   node01.netology.yc   Ready     Active         Leader           20.10.17
s1jdgobweci1qfvf1sb6guuk5     node02.netology.yc   Ready     Active         Reachable        20.10.17
scti70shglq5agx2jz0te56bm     node03.netology.yc   Ready     Active         Reachable        20.10.17
3oak4md76d7kk4go2gd6bteol     node04.netology.yc   Ready     Active                          20.10.17
k4mtwguvox9q2rbnayw4zmstn     node05.netology.yc   Ready     Active                          20.10.17
vbky9sire60g69njdw8vk8uyp     node06.netology.yc   Ready     Active                          20.10.17
```

![��������](01-01.jpg)
![���������](01-02.jpg)


## ������ 3

������� ��� ������, ������� � ������ ������������ ������� �����������, ��������� �� ����� �������������.
��� ��������� ������, ��� ���������� ������������ �������� �� ��������� (�������), � ������� �������:
```
docker service ls
```
### ����� �� ������ 3

```
[centos@node01 ~]$ sudo docker service ls
ID             NAME                                MODE         REPLICAS   IMAGE                                          PORTS
ehi0x82eo4ka   swarm_monitoring_alertmanager       replicated   1/1        stefanprodan/swarmprom-alertmanager:v0.14.0
9w9fcdu2s9yb   swarm_monitoring_caddy              replicated   1/1        stefanprodan/caddy:latest                      *:3000->3000/tcp, *:9090->9090/tcp, *:9093-9094->9093-9094/tcp
6v4dlnq073ws   swarm_monitoring_cadvisor           global       6/6        google/cadvisor:latest
ii7k8f4ey5k1   swarm_monitoring_dockerd-exporter   global       6/6        stefanprodan/caddy:latest
99a2gn97cuvo   swarm_monitoring_grafana            replicated   1/1        stefanprodan/swarmprom-grafana:5.3.4
e062str4ba5y   swarm_monitoring_node-exporter      global       6/6        stefanprodan/swarmprom-node-exporter:v0.16.0
ldz13pt14v8v   swarm_monitoring_prometheus         replicated   1/1        stefanprodan/swarmprom-prometheus:v2.5.0
evkx7jg6xfy0   swarm_monitoring_unsee              replicated   1/1        cloudflare/unsee:v0.8.0
```


![��������](02-01.jpg)
![���������](02-02.jpg)
![���������](02-03.jpg)

## ������ 4 (*)

��������� �� ������ Docker Swarm �������� ������� (��������� ����) � ���� ���������� �������� � �����������, ��� ��� ������ � ����� ��� �����:
```
# ��.������������: https://docs.docker.com/engine/swarm/swarm_manager_locking/
docker swarm update --autolock=true
```

### ����� �� ������ 4

--autolock=true ��������� ������� ���� ������������� �� ����, ����� ��� ����� ������ �������������� � ��������, ���� ���� ������������. ����� ��� ������ ������� � �����, ����� ������ ���� �������� ������ ��� �����.

```
[centos@node01 ~]$ sudo docker swarm update --autolock=false
Swarm updated.
```

```
vagrant@dev-docker:~/05-virt-05-docker-swarm/src/terraform$ ssh centos@51.250.82.3
[centos@node03 ~]$ sudo docker swarm update --autolock=true
Swarm updated.
To unlock a swarm manager after it restarts, run the `docker swarm unlock`
command and provide the following key:

    SWMKEY-1-uhsdzKY6FnxrOQ9PcZhiwBg/UajORtaBadYri6djg0g

Please remember to store this key in a password manager, since without it you
will not be able to restart the manager.
[centos@node03 ~]$ sudo docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
xyr7u8f0mvr24ycpztingw69v     node01.netology.yc   Ready     Active         Leader           20.10.17
s1jdgobweci1qfvf1sb6guuk5     node02.netology.yc   Ready     Active         Reachable        20.10.17
scti70shglq5agx2jz0te56bm *   node03.netology.yc   Ready     Active         Reachable        20.10.17
3oak4md76d7kk4go2gd6bteol     node04.netology.yc   Ready     Active                          20.10.17
k4mtwguvox9q2rbnayw4zmstn     node05.netology.yc   Ready     Active                          20.10.17
vbky9sire60g69njdw8vk8uyp     node06.netology.yc   Ready     Active                          20.10.17
```

```
[centos@node03 ~]$ sudo docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
xyr7u8f0mvr24ycpztingw69v     node01.netology.yc   Down      Active         Unreachable      20.10.17
s1jdgobweci1qfvf1sb6guuk5     node02.netology.yc   Ready     Active         Leader           20.10.17
scti70shglq5agx2jz0te56bm *   node03.netology.yc   Ready     Active         Reachable        20.10.17
3oak4md76d7kk4go2gd6bteol     node04.netology.yc   Ready     Active                          20.10.17
k4mtwguvox9q2rbnayw4zmstn     node05.netology.yc   Ready     Active                          20.10.17
vbky9sire60g69njdw8vk8uyp     node06.netology.yc   Ready     Active                          20.10.17
```

```[centos@node01 ~]$ sudo docker swarm unlock```

����� ���������:
```[centos@node01 ~]$ sudo docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
xyr7u8f0mvr24ycpztingw69v *   node01.netology.yc   Ready     Active         Reachable        20.10.17
s1jdgobweci1qfvf1sb6guuk5     node02.netology.yc   Ready     Active         Leader           20.10.17
scti70shglq5agx2jz0te56bm     node03.netology.yc   Ready     Active         Reachable        20.10.17
3oak4md76d7kk4go2gd6bteol     node04.netology.yc   Ready     Active                          20.10.17
k4mtwguvox9q2rbnayw4zmstn     node05.netology.yc   Ready     Active                          20.10.17
vbky9sire60g69njdw8vk8uyp     node06.netology.yc   Ready     Active                          20.10.17```

---

### Finale

� �� �������� �������:

```
vagrant@dev-docker:~/05-virt-05-docker-swarm/src/terraform$ terraform destroy

Destroy complete! Resources: 12 destroyed.
```

� ������� ���� � �������, � ����� ��������� ���������� ������.