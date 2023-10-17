# Домашнее задание к занятию «Запуск приложений в K8S»

### Цель задания

В тестовой среде для работы с Kubernetes, установленной в предыдущем ДЗ, необходимо развернуть Deployment с приложением, состоящим из нескольких контейнеров, и масштабировать его.

------

### Задание 1. Создать Deployment и обеспечить доступ к репликам приложения из другого Pod

1. Создать Deployment приложения, состоящего из двух контейнеров — nginx и multitool. Решить возникшую ошибку.
2. После запуска увеличить количество реплик работающего приложения до 2.
3. Продемонстрировать количество подов до и после масштабирования.
4. Создать Service, который обеспечит доступ до реплик приложений из п.1.
5. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложений из п.1.

#### Ответ к заданию 1

Сделали манифест [deployment-v1.yml](deployment-v1.yml) и запустили:

```
# kubectl apply -f deployment.yml
deployment.apps/multitooldep created

и закономерно получили ошибку:

multitooldep-86f89554df-mdpcp   1/2     Error     1 (16s ago)     21s
```

Дебаг:

```
# kubectl logs pods/multitooldep-86f89554df-mdpcp
Defaulted container "nginx" out of: nginx, multitool
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2023/10/16 15:47:20 [notice] 1#1: using the "epoll" event method
2023/10/16 15:47:20 [notice] 1#1: nginx/1.25.2
2023/10/16 15:47:20 [notice] 1#1: built by gcc 12.2.0 (Debian 12.2.0-14)
2023/10/16 15:47:20 [notice] 1#1: OS: Linux 5.15.0-60-generic
2023/10/16 15:47:20 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 65536:65536
2023/10/16 15:47:20 [notice] 1#1: start worker processes
2023/10/16 15:47:20 [notice] 1#1: start worker process 29
2023/10/16 15:47:20 [notice] 1#1: start worker process 30
```

Похоже нам недостает environment variables

```
 env:
        - name: HTTP_PORT
          value: "8080"
        - name: HTTPS_PORT
          value: "11443"
```

Добавили новый манифест [deployment-v2.yml](deployment-v2.yml)

Успешно стартовали:

```
NAME                            READY   STATUS    RESTARTS        AGE
hello-node-f9f86cb6b-xkm9p      1/1     Running   2 (4d13h ago)   4d13h
hellopod                        1/1     Running   0               3d1h
helloworldpod                   1/1     Running   0               3d1h
netology-web                    1/1     Running   0               2d20h
multitooldep-66db5d96d4-jvvbs   2/2     Running   0               7m17s
```

Увеличиваем количество реплик:

```
# kubectl scale deployment multitooldep --replicas 2
deployment.apps/multitooldep scaled

# kubectl get pods
NAME                            READY   STATUS    RESTARTS        AGE
hello-node-f9f86cb6b-xkm9p      1/1     Running   2 (4d13h ago)   4d13h
hellopod                        1/1     Running   0               3d2h
helloworldpod                   1/1     Running   0               3d2h
netology-web                    1/1     Running   0               2d20h
multitooldep-66db5d96d4-jvvbs   2/2     Running   0               32m
multitooldep-66db5d96d4-htcb6   2/2     Running   0               7s
```

И теперь через файл деплоймента.. увеличим до 3х реплик:

```
# kubectl apply -f deployment.yml
deployment.apps/multitooldep configured

# kubectl get pods
NAME                            READY   STATUS    RESTARTS        AGE
hello-node-f9f86cb6b-xkm9p      1/1     Running   2 (4d13h ago)   4d13h
hellopod                        1/1     Running   0               3d2h
helloworldpod                   1/1     Running   0               3d2h
netology-web                    1/1     Running   0               2d20h
multitooldep-66db5d96d4-jvvbs   2/2     Running   0               34m
multitooldep-66db5d96d4-htcb6   2/2     Running   0               90s
multitooldep-66db5d96d4-j5nkf   2/2     Running   0               5s
```

Создаем дополнительный сервис из манифеста [service.yml](service.yml)

```
# kubectl get svc -o wide
NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE     SELECTOR
kubernetes     ClusterIP   10.152.183.1     <none>        443/TCP    5d1h    <none>
netology-svc   ClusterIP   10.152.183.218   <none>        8888/TCP   2d20h   app=netology-web
```

```
# kubectl apply -f service.yml
service/multitool-svc created

# kubectl get svc -o wide
NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)           AGE     SELECTOR
kubernetes      ClusterIP   10.152.183.1     <none>        443/TCP           5d1h    <none>
netology-svc    ClusterIP   10.152.183.218   <none>        8888/TCP          2d20h   app=netology-web
multitool-svc   ClusterIP   10.152.183.184   <none>        80/TCP,8080/TCP   6s      app=multitool
```

```
# kubectl describe service multitool-svc
Name:              multitool-svc
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          app=multitool
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.152.183.184
IPs:               10.152.183.184
Port:              nginxadditional  80/TCP
TargetPort:        80/TCP
Endpoints:         10.1.196.168:80,10.1.196.169:80,10.1.196.170:80
Port:              multitooladditional  8080/TCP
TargetPort:        8080/TCP
Endpoints:         10.1.196.168:8080,10.1.196.169:8080,10.1.196.170:8080
Session Affinity:  None
Events:            <none>
```

Проверяем доступ:
```
microk8s kubectl port-forward services/multitool-svc 3000:80 --address="0.0.0.0"
```
[001](001.png)

```
microk8s kubectl port-forward services/multitool-svc 3000:8080 --address="0.0.0.0"
```

[002](002.png)


Создаем отдельный Pod с приложением multitool и убеждаемся с помощью curl, что из пода есть доступ до приложений из п.1. -- манифест

```
# kubectl apply -f deployment-v3-multitool.yml
pod/multitool3 created
```

```
# kubectl get pods -o wide
NAME                            READY   STATUS    RESTARTS        AGE     IP             NODE          NOMINATED NODE   READINESS GATES
hello-node-f9f86cb6b-xkm9p      1/1     Running   2 (4d13h ago)   4d13h   10.1.196.153   kub.nobr.ru   <none>           <none>
hellopod                        1/1     Running   0               3d2h    10.1.196.157   kub.nobr.ru   <none>           <none>
helloworldpod                   1/1     Running   0               3d2h    10.1.196.158   kub.nobr.ru   <none>           <none>
netology-web                    1/1     Running   0               2d20h   10.1.196.159   kub.nobr.ru   <none>           <none>
multitooldep-66db5d96d4-jvvbs   2/2     Running   0               48m     10.1.196.168   kub.nobr.ru   <none>           <none>
multitooldep-66db5d96d4-htcb6   2/2     Running   0               15m     10.1.196.169   kub.nobr.ru   <none>           <none>
multitooldep-66db5d96d4-j5nkf   2/2     Running   0               14m     10.1.196.170   kub.nobr.ru   <none>           <none>
multitool3                      1/1     Running   0               62s     10.1.196.171   kub.nobr.ru   <none>           <none>
```

```
# kubectl describe service multitool-svc
Name:              multitool-svc
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          app=multitool
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.152.183.184
IPs:               10.152.183.184
Port:              nginxadditional  80/TCP
TargetPort:        80/TCP
Endpoints:         10.1.196.168:80,10.1.196.169:80,10.1.196.170:80 + 1 more...
Port:              multitooladditional  8080/TCP
TargetPort:        8080/TCP
Endpoints:         10.1.196.168:8080,10.1.196.169:8080,10.1.196.170:8080 + 1 more...
Session Affinity:  None
Events:            <none>
```

```
# microk8s kubectl exec multitool3 -- curl 10.1.196.168:80
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   615  100   615    0     0   418k      0 --:--:-- --:--:-- --:--:--  600k
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   615  100   615    0     0   466k      0 --:--:-- --:--:-- --:--:--  600k
```

```
# microk8s kubectl exec multitool3 -- curl 10.1.196.169:80
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   615  100   615    0     0   619k      0 --:--:-- --:--:-- --:--:--  600k
```

```
# microk8s kubectl exec multitool3 -- curl 10.1.196.170:80
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   615  100   615    0     0   466k      0 --:--:-- --:--:-- --:--:--  600k
```

------

### Задание 2. Создать Deployment и обеспечить старт основного контейнера при выполнении условий

1. Создать Deployment приложения nginx и обеспечить старт контейнера только после того, как будет запущен сервис этого приложения.
2. Убедиться, что nginx не стартует. В качестве Init-контейнера взять busybox.
3. Создать и запустить Service. Убедиться, что Init запустился.
4. Продемонстрировать состояние пода до и после запуска сервиса.

#### Ответ к заданию 2

1. Создаем сервис

Манифест - [deployment-v4.yml] (deployment-v4.yml)

```
# kubectl apply -f deployment-v4.yml
deployment.apps/nginx-deploy created
```
2. Убеждаемся

```
# kubectl get pods
NAME                            READY   STATUS     RESTARTS     AGE
hello-node-f9f86cb6b-xkm9p      1/1     Running    2 (5d ago)   5d
hellopod                        1/1     Running    0            3d13h
helloworldpod                   1/1     Running    0            3d13h
netology-web                    1/1     Running    0            3d7h
multitooldep-66db5d96d4-jvvbs   2/2     Running    0            11h
multitooldep-66db5d96d4-htcb6   2/2     Running    0            10h
multitooldep-66db5d96d4-j5nkf   2/2     Running    0            10h
multitool3                      1/1     Running    0            10h
nginx-deploy-5bfb65c7c-cvgjt    0/1     Init:0/1   0            27s
```

```
# kubectl logs nginx-deploy-5bfb65c7c-cvgjt
Defaulted container "nginx" out of: nginx, init-test-nslookup (init)
Error from server (BadRequest): container "nginx" in pod "nginx-deploy-5bfb65c7c-cvgjt" is waiting to start: PodInitializing

# kubectl logs nginx-deploy-5bfb65c7c-cvgjt  init-test-nslookup
Server:         10.152.183.10
Address:        10.152.183.10:53

** server can't find my-svc.default.svc.cluster.local: NXDOMAIN
** server can't find my-svc.default.svc.cluster.local: NXDOMAIN

waiting for my-svc
Server:         10.152.183.10
Address:        10.152.183.10:53
```

3. Создаем сервис

[deployment-v4-svc.yml](deployment-v4-svc)

```
# kubectl apply -f deployment-v4-svc.yml
service/my-svc created
```

4. Демонстрация

```
# kubectl get pods -o wide
NAME                            READY   STATUS    RESTARTS     AGE     IP             NODE          NOMINATED NODE   READINESS GATES
hello-node-f9f86cb6b-xkm9p      1/1     Running   2 (5d ago)   5d      10.1.196.153   kub.nobr.ru   <none>           <none>
hellopod                        1/1     Running   0            3d13h   10.1.196.157   kub.nobr.ru   <none>           <none>
helloworldpod                   1/1     Running   0            3d13h   10.1.196.158   kub.nobr.ru   <none>           <none>
netology-web                    1/1     Running   0            3d7h    10.1.196.159   kub.nobr.ru   <none>           <none>
multitooldep-66db5d96d4-jvvbs   2/2     Running   0            11h     10.1.196.168   kub.nobr.ru   <none>           <none>
multitooldep-66db5d96d4-htcb6   2/2     Running   0            11h     10.1.196.169   kub.nobr.ru   <none>           <none>
multitooldep-66db5d96d4-j5nkf   2/2     Running   0            11h     10.1.196.170   kub.nobr.ru   <none>           <none>
multitool3                      1/1     Running   0            10h     10.1.196.171   kub.nobr.ru   <none>           <none>
nginx-deploy-5bfb65c7c-cvgjt    1/1     Running   0            5m21s   10.1.196.172   kub.nobr.ru   <none>           <none>
```

```
# kubectl logs nginx-deploy-5bfb65c7c-cvgjt  init-test-nslookup

Name:   my-svc.default.svc.cluster.local
Address: 10.152.183.207
```
