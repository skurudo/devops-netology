# Домашнее задание к занятию «Kubernetes. Причины появления. Команда kubectl»

### Цель задания

Для экспериментов и валидации ваших решений вам нужно подготовить тестовую среду для работы с Kubernetes. Оптимальное решение — развернуть на рабочей машине или на отдельной виртуальной машине MicroK8S.

------

### Задание 1. Установка MicroK8S

1. Установить MicroK8S на локальную машину или на удалённую виртуальную машину.
2. Установить dashboard.
3. Сгенерировать сертификат для подключения к внешнему ip-адресу.


#### Ответ к заданию 1 - Установка MicroK8S
 
 1. Установка


```
apt update
sudo apt install snapd
sudo snap install microk8s --classic
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
```

Вывод команд для проверки

```
# microk8s version
MicroK8s v1.27.5 revision 5891
```

```
# microk8s status --wait-ready
microk8s is running
high-availability: no
  datastore master nodes: 127.0.0.1:19001
  datastore standby nodes: none
...
```

```
# microk8s kubectl get nodes
NAME          STATUS   ROLES    AGE     VERSION
kub.nobr.ru   Ready    <none>   2m43s   v1.27.5
```

2. Dashboard

```
# microk8s enable dashboard
Infer repository core for addon dashboard
Enabling Kubernetes Dashboard
Infer repository core for addon metrics-server
Enabling Metrics-Server
```

```
# microk8s status
microk8s is running
high-availability: no
  datastore master nodes: 127.0.0.1:19001
  datastore standby nodes: none
addons:
  enabled:
    dashboard            # (core) The Kubernetes dashboard
    dns                  # (core) CoreDNS
    ha-cluster           # (core) Configure high availability on the current node
    helm                 # (core) Helm - the package manager for Kubernetes
    helm3                # (core) Helm 3 - the package manager for Kubernetes
    metrics-server       # (core) K8s Metrics Server for API access to service metrics
```

3. Сертификат

Добавляем адрес:
```
 nano /var/snap/microk8s/current/certs/csr.conf.template

 [ alt_names ]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster
DNS.5 = kubernetes.default.svc.cluster.local
IP.1 = 127.0.0.1
IP.2 = 10.152.183.1
**IP.3 = 94.103.xxx.xxx**
```

Обновляем, перезапускаем
```
# sudo microk8s refresh-certs --cert front-proxy-client.crt
Taking a backup of the current certificates under /var/snap/microk8s/5891/certs-backup/
Creating new certificates
Signature ok
subject=CN = front-proxy-client
Getting CA Private Key
Restarting service kubelite.
```


------

### Задание 2. Установка и настройка локального kubectl
1. Установить на локальную машину kubectl.
2. Настроить локально подключение к кластеру.
3. Подключиться к дашборду с помощью port-forward.

#### Ответ к заданию 2 - Установка и настройка локального kubectl

1. Устновка по инструкции

```
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

настройка автодополнения в текущую сессию bash source <(kubectl completion bash);
добавление автодополнения в командную оболочку bash echo "source <(kubectl completion bash)" >> ~/.bashrc
```

```
# kubectl version
Client Version: v1.28.2
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
Server Version: v1.27.5
```

2. Локальное подключение:
   
```
# kubectl cluster-info
Kubernetes control plane is running at https://94.103.xxx.xxx:16443
CoreDNS is running at https://94.103.xxx.xxx:16443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

```
# kubectl get nodes
NAME          STATUS   ROLES    AGE   VERSION
kub.nobr.ru   Ready    <none>   11h   v1.27.5
```

```
# kubectl get services --all-namespaces
NAMESPACE     NAME                        TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
default       kubernetes                  ClusterIP   10.152.183.1     <none>        443/TCP                  11h
kube-system   kube-dns                    ClusterIP   10.152.183.10    <none>        53/UDP,53/TCP,9153/TCP   11h
kube-system   metrics-server              ClusterIP   10.152.183.189   <none>        443/TCP                  11h
kube-system   kubernetes-dashboard        ClusterIP   10.152.183.133   <none>        443/TCP                  11h
kube-system   dashboard-metrics-scraper   ClusterIP   10.152.183.221   <none>        8000/TCP                 11h
```

3. Подключение с port-forward

Проброс порта
```
# microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443
Forwarding from 127.0.0.1:10443 -> 8443
Forwarding from [::1]:10443 -> 8443
```

Грустный локальный вывод с удаленной машины
```
# curl --insecure https://127.0.01:10443
<!--
Copyright 2017 The Kubernetes Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
--><!DOCTYPE html><html lang="en" dir="ltr"><head>
  <meta charset="utf-8">
  <title>Kubernetes Dashboard</title>
  <link rel="icon" type="image/png" href="assets/images/kubernetes-logo.png">
  <meta name="viewport" content="width=device-width">
<style>html,body{height:100%;margin:0}*::-webkit-scrollbar{background:transparent;height:8px;width:8px}</style><link rel="stylesheet" href="styles.243e6d874431c8e8.css" media="print" onload="this.media='all'"><noscript><link rel="stylesheet" href="styles.243e6d874431c8e8.css"></noscript></head>

<body>
  <kd-root></kd-root>
<script src="runtime.134ad7745384bed8.js" type="module"></script><script src="polyfills.5c84b93f78682d4f.js" type="module"></script><script src="scripts.2c4f58d7c579cacb.js" defer></script><script src="en.main.3550e3edca7d0ed8.js" type="module"></script>
```

Но есть менее грустная история... и без использования proxy

Включаем host-access
```
microk8s enable host-access
```

Небольшая корректура сервиса
```
kubectl -n kube-system edit service kubernetes-dashboard
```

По умолчанию у нас "type: clusterIP", меняем на "type: NodePort"

```
# kubectl -n kube-system get services
NAME                        TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
kube-dns                    ClusterIP   10.152.183.10    <none>        53/UDP,53/TCP,9153/TCP   12h
metrics-server              ClusterIP   10.152.183.189   <none>        443/TCP                  12h
dashboard-metrics-scraper   ClusterIP   10.152.183.221   <none>        8000/TCP                 12h
kubernetes-dashboard        NodePort    10.152.183.133   <none>        443:**30303**/TCP            12h
```

Подключаемся к https://наш-ip-адрес:30303

И не забываем сделать токен:
```
token=$(kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
kubectl -n kube-system describe secret $token
```



---

Можно столкнуться с такой ошибкой:
```
# kubectl get nodes
E1012 05:54:13.982860   20996 memcache.go:265] couldn't get current server API group list: Get "http://localhost:8080/api?timeout=32s": dial tcp 127.0.0.1:8080: connect: connection refused
E1012 05:54:13.983229   20996 memcache.go:265] couldn't get current server API group list: Get "http://localhost:8080/api?timeout=32s": dial tcp 127.0.0.1:8080: connect: connection refused
E1012 05:54:13.984639   20996 memcache.go:265] couldn't get current server API group list: Get "http://localhost:8080/api?timeout=32s": dial tcp 127.0.0.1:8080: connect: connection refused
E1012 05:54:13.986019   20996 memcache.go:265] couldn't get current server API group list: Get "http://localhost:8080/api?timeout=32s": dial tcp 127.0.0.1:8080: connect: connection refused
E1012 05:54:13.987334   20996 memcache.go:265] couldn't get current server API group list: Get "http://localhost:8080/api?timeout=32s": dial tcp 127.0.0.1:8080: connect: connection refused
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```
Решение:

Проверить работу microk8s
```
microk8s config
```

Исправить ошибку:
```
cd $HOME
mkdir .kube
cd .kube
microk8s config > config
```

---

------

### Правила приёма работы

1. Домашняя работа оформляется в своём Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода команд `kubectl get nodes` и скриншот дашборда.

------

### Критерии оценки
Зачёт — выполнены все задания, ответы даны в развернутой форме, приложены соответствующие скриншоты и файлы проекта, в выполненных заданиях нет противоречий и нарушения логики.

На доработку — задание выполнено частично или не выполнено, в логике выполнения заданий есть противоречия, существенные недостатки.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция](https://microk8s.io/docs/getting-started) по установке MicroK8S.
2. [Инструкция](https://kubernetes.io/ru/docs/reference/kubectl/cheatsheet/#bash) по установке автодополнения **kubectl**.
3. [Шпаргалка](https://kubernetes.io/ru/docs/reference/kubectl/cheatsheet/) по **kubectl**.
