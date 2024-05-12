# Домашнее задание к занятию Troubleshooting

### Цель задания

Устранить неисправности при деплое приложения.

### Чеклист готовности к домашнему заданию

1. Кластер K8s.

### Задание. При деплое приложение web-consumer не может подключиться к auth-db. Необходимо это исправить

1. Установить приложение по команде:
```shell
kubectl apply -f https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml
```
2. Выявить проблему и описать.
3. Исправить проблему, описать, что сделано.
4. Продемонстрировать, что проблема решена.

### Ответ к заданию

1. Выполнение команды по заданию.

Первое с чем мы столкнемся - то, что у нас нет namespace'ов data и web. Добавим их и выполненим деплой.
(действия мы проводим с локальным файлом, будет выложен ниже)

```
apiVersion: v1
kind: Namespace
metadata:
  name: web
---
apiVersion: v1
kind: Namespace
metadata:
  name: data
```

```
vagrant@master:~$ kubectl apply -f task2.yaml
namespace/web created
namespace/data created
deployment.apps/web-consumer created
deployment.apps/auth-db created
service/auth-db created
```

2. Что-то у нас такое создалось.. посмотрим, что там внутри

В namespace *web* что-то запустилось и работает
```
vagrant@master:~$ kubectl get all -n web
NAME                                READY   STATUS    RESTARTS   AGE
pod/web-consumer-5f87765478-q7hl9   1/1     Running   0          3m27s
pod/web-consumer-5f87765478-wsz7w   1/1     Running   0          3m28s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/web-consumer   2/2     2            2           3m28s

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/web-consumer-5f87765478   2         2         2       3m28s
```
В namespace *data* что-то тоже запустилось и работает
```
vagrant@master:~$ kubectl get all -n data
NAME                           READY   STATUS    RESTARTS   AGE
pod/auth-db-7b5cdbdc77-klszh   1/1     Running   0          4m12s

NAME              TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/auth-db   ClusterIP   10.233.8.154   <none>        80/TCP    4m12s

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/auth-db   1/1     1            1           4m13s

NAME                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/auth-db-7b5cdbdc77   1         1         1       4m13s
```

Самое время смотреть логи...

```
vagrant@master:~$ kubectl logs -n data auth-db-7b5cdbdc77-klszh
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
```

И здесь вроде бы ничего необычного, смотрим дальше...

```
vagrant@master:~$ kubectl logs -n web web-consumer-5f87765478-q7hl9
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
```

Не может отрезолвить хост.

3. Поскольку у нас поды в разных неймспейсах, а не в одном, нужно им на это как-то намекнуть. Т.е. дать указание, куда именно нужно стучаться за данными. Для этого немного меняем манифест в части curl и запускаем деплой еще раз.

```
- while true; do curl auth-db.data; sleep 5; done
```

```
kubectl apply -f task.yaml
```

```
vagrant@master:~$ kubectl get all -n web
NAME                                READY   STATUS    RESTARTS   AGE
pod/web-consumer-76669b5d6d-2cm8h   1/1     Running   0          66s
pod/web-consumer-76669b5d6d-2fzss   1/1     Running   0          70s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/web-consumer   2/2     2            2           10m

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/web-consumer-5f87765478   0         0         0       10m
replicaset.apps/web-consumer-76669b5d6d   2         2         2       70s
```

4. После того, как мы обождали, что все применится, можем проверить.

```
vagrant@master:~$ kubectl logs -n web web-consumer-76669b5d6d-2cm8h
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   612  100   612    0     0   4439      0 --:--:-- --:--:-- --:--:--  199k
```

Исправленный манифест прилагается... [task_fixed](task_fixed.yaml)