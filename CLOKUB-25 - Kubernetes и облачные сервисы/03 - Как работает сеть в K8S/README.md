# Домашнее задание к занятию «Как работает сеть в K8s»

### Цель задания

Настроить сетевую политику доступа к подам.

### Чеклист готовности к домашнему заданию

1. Кластер K8s с установленным сетевым плагином Calico.

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Документация Calico](https://www.tigera.io/project-calico/).
2. [Network Policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/).
3. [About Network Policy](https://docs.projectcalico.org/about/about-network-policy).

-----

### Задание 1. Создать сетевую политику или несколько политик для обеспечения доступа

1. Создать deployment'ы приложений frontend, backend и cache и соответсвующие сервисы.
2. В качестве образа использовать network-multitool.
3. Разместить поды в namespace App.
4. Создать политики, чтобы обеспечить доступ frontend -> backend -> cache. Другие виды подключений должны быть запрещены.
5. Продемонстрировать, что трафик разрешён и запрещён.

### Ответ к заданию 1. Создать сетевую политику или несколько политик для обеспечения доступа

1. Создать deployment'ы приложений frontend, backend и cache и соответсвующие сервисы.
2. В качестве образа использовать network-multitool.
3. Разместить поды в namespace App.

Создание отдельного неймспейса и деплойметов:
* [namespace.yaml](namespace.yaml)
* [frontend.yaml](frontend.yaml)
* [backend.yaml](backend.yaml)
* [cache.yaml](cache.yaml)

```
vagrant@master:~$  kubectl apply -f namespace.yaml
namespace/hw03 created

vagrant@master:~$ kubectl apply -f frontend.yaml
deployment.apps/frontend created
service/frontend created

vagrant@master:~$ kubectl apply -f backend.yaml
deployment.apps/backend created
service/backend created

vagrant@master:~$ kubectl apply -f cache.yaml
deployment.apps/cache created
service/cache created
```

```
vagrant@master:~$  kubectl config set-context --current --namespace=hw03
Context "kubernetes-admin@cluster.local" modified.

vagrant@master:~$ kubectl get all -o wide
NAME                            READY   STATUS    RESTARTS   AGE     IP             NODE    NOMINATED NODE   READINESS GATES
pod/backend-6478c64696-bqq2l    1/1     Running   0          3m7s    10.233.74.69   node4   <none>           <none>
pod/cache-575bd6d866-mtvqg      1/1     Running   0          91s     10.233.71.5    node3   <none>           <none>
pod/frontend-7c96b4cbfb-tfvd8   1/1     Running   0          3m37s   10.233.75.5    node2   <none>           <none>

NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE     SELECTOR
service/backend    ClusterIP   10.233.36.215   <none>        80/TCP    3m7s    app=backend
service/cache      ClusterIP   10.233.39.214   <none>        80/TCP    91s     app=cache
service/frontend   ClusterIP   10.233.12.129   <none>        80/TCP    3m37s   app=frontend

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS          IMAGES                                  SELECTOR
deployment.apps/backend    1/1     1            1           3m7s    network-multitool   praqma/network-multitool:alpine-extra   app=backend
deployment.apps/cache      1/1     1            1           91s     network-multitool   praqma/network-multitool:alpine-extra   app=cache
deployment.apps/frontend   1/1     1            1           3m37s   network-multitool   praqma/network-multitool:alpine-extra   app=frontend

NAME                                  DESIRED   CURRENT   READY   AGE     CONTAINERS          IMAGES                                  SELECTOR
replicaset.apps/backend-6478c64696    1         1         1       3m7s    network-multitool   praqma/network-multitool:alpine-extra   app=backend,pod-template-hash=6478c64696
replicaset.apps/cache-575bd6d866      1         1         1       91s     network-multitool   praqma/network-multitool:alpine-extra   app=cache,pod-template-hash=575bd6d866
replicaset.apps/frontend-7c96b4cbfb   1         1         1       3m37s   network-multitool   praqma/network-multitool:alpine-extra   app=frontend,pod-template-hash=7c96b4cbfb
```

4. Создать политики, чтобы обеспечить доступ frontend -> backend -> cache. Другие виды подключений должны быть запрещены.

* [policies.yaml](policies.yaml)

```
vagrant@master:~$ kubectl apply -f policies.yaml
networkpolicy.networking.k8s.io/default-deny-ingress created
networkpolicy.networking.k8s.io/frontend-to-backend-policy created
networkpolicy.networking.k8s.io/backend-to-cache-policy created
```

5. Продемонстрировать, что трафик разрешён и запрещён.

Работает:

```
vagrant@master:~$ kubectl exec frontend-7c96b4cbfb-tfvd8 -- curl backend 

% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0Praqma Network MultiTool (with NGINX) - backend-6478c64696-bqq2l - 10.233.74.69
100    80  100    80    0     0   3391      0 --:--:-- --:--:-- --:--:--  3478
```

```
vagrant@master:~$ kubectl exec backend-6478c64696-bqq2l -- curl cache

  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0Praqma Network MultiTool (with NGINX) - cache-575bd6d866-mtvqg - 10.233.71.5
100    77  100    77    0     0   2943      0 --:--:-- --:--:-- --:--:--  2961
```

Не работает:

```
vagrant@master:~$ kubectl exec cache-575bd6d866-mtvqg -- curl backend

  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:12 --:--:--     0^C
```

```
vagrant@master:~$ kubectl exec cache-575bd6d866-mtvqg -- curl frontend

  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:15 --:--:--     0^C
```

```
vagrant@master:~$ kubectl exec backend-6478c64696-bqq2l -- curl frontend

  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:13 --:--:--     0^C
```

```
vagrant@master:~$ kubectl exec frontend-7c96b4cbfb-tfvd8 -- curl cache

  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:18 --:--:--     0^C
```