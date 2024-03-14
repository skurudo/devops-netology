# Домашнее задание к занятию «Helm»

### Цель задания

В тестовой среде Kubernetes необходимо установить и обновить приложения с помощью Helm.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция](https://helm.sh/docs/intro/install/) по установке Helm. [Helm completion](https://helm.sh/docs/helm/helm_completion/).

```
# helm
Command 'helm' not found

# snap install helm --classic

# helm version
version.BuildInfo{Version:"v3.14.3", GitCommit:"f03cc04caaa8f6d7c3e67cf918929150cf6f3f12", GitTreeState:"clean", GoVersion:"go1.21.7"}
```

------

### Задание 1. Подготовить Helm-чарт для приложения

1. Необходимо упаковать приложение в чарт для деплоя в разные окружения. 
2. Каждый компонент приложения деплоится отдельным deployment’ом или statefulset’ом.
3. В переменных чарта измените образ приложения для изменения версии.

#### Ответ на задание 1

1. Необходимо упаковать приложение в чарт для деплоя в разные окружения. 

Папка с приложением - [myapp](myapp)

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-nginx-deployment
  namespace: {{ .Release.Namespace }}
  labels:
    app: myapp-nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp-nginx
  template:
    metadata:
      labels:
        app: myapp-nginx
    spec:
      containers:
      - name: {{ .Release.Name }}-nginx
        image: "nginx:{{ .Values.nginx_version.tag }}"
        ports:
        - containerPort: 80
```

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-multitool-deployment
  namespace: {{ .Release.Namespace }}
  labels:
    app: myapp-multitool
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp-multitool
  template:
    metadata:
      labels:
        app: myapp-multitool
    spec:
      containers:
      - name: {{ .Release.Name }}-multitool
        image: "wbitt/network-multitool:{{ .Values.multitool_version.tag }}"
        ports:
        - containerPort: 80
        env:
        - name: HTTP_PORT
          value: "80"
```


2. Каждый компонент приложения деплоится отдельным deployment’ом или statefulset’ом.

```
~#  helm template myapp
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /root/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /root/.kube/config
---
# Source: myapp/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: release-name-nginx-svc
  namespace: default
spec:
  selector:
    app: myapp-nginx
  ports:
  - port: 80
    targetPort: 80
---
# Source: myapp/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: release-name-multitool-svc
  namespace: default
spec:
  selector:
    app: myapp-multitool
  ports:
  - port: 80
    targetPort: 80
---
# Source: myapp/templates/depl-multitool.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: release-name-multitool-deployment
  namespace: default
  labels:
    app: myapp-multitool
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp-multitool
  template:
    metadata:
      labels:
        app: myapp-multitool
    spec:
      containers:
      - name: release-name-multitool
        image: "wbitt/network-multitool:alpine-minimal"
        ports:
        - containerPort: 80
        env:
        - name: HTTP_PORT
          value: "80"
---
# Source: myapp/templates/depl-nginx.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: release-name-nginx-deployment
  namespace: default
  labels:
    app: myapp-nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp-nginx
  template:
    metadata:
      labels:
        app: myapp-nginx
    spec:
      containers:
      - name: release-name-nginx
        image: "nginx:1.24"
        ports:
        - containerPort: 80
```

3. В переменных чарта измените образ приложения для изменения версии.

```
~# helm template -f myapp/values2.yaml myapp
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /root/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /root/.kube/config
---
# Source: myapp/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: release-name-nginx-svc
  namespace: default
spec:
  selector:
    app: myapp-nginx
  ports:
  - port: 80
    targetPort: 80
---
# Source: myapp/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: release-name-multitool-svc
  namespace: default
spec:
  selector:
    app: myapp-multitool
  ports:
  - port: 80
    targetPort: 80
---
# Source: myapp/templates/depl-multitool.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: release-name-multitool-deployment
  namespace: default
  labels:
    app: myapp-multitool
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp-multitool
  template:
    metadata:
      labels:
        app: myapp-multitool
    spec:
      containers:
      - name: release-name-multitool
        image: "wbitt/network-multitool:latest"
        ports:
        - containerPort: 80
        env:
        - name: HTTP_PORT
          value: "80"
---
# Source: myapp/templates/depl-nginx.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: release-name-nginx-deployment
  namespace: default
  labels:
    app: myapp-nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp-nginx
  template:
    metadata:
      labels:
        app: myapp-nginx
    spec:
      containers:
      - name: release-name-nginx
        image: "nginx:1.25"
        ports:
        - containerPort: 80
```

------

### Задание 2. Запустить две версии в разных неймспейсах

1. Подготовив чарт, необходимо его проверить. Запуститe несколько копий приложения.
2. Одну версию в namespace=app1, вторую версию в том же неймспейсе, третью версию в namespace=app2.
3. Продемонстрируйте результат.

#### Ответ на задание 2

1. Подготовив чарт, необходимо его проверить. Запуститe несколько копий приложения.

 ```
 # helm install myapp myapp

NAME: myapp
LAST DEPLOYED: Thu Mar 14 17:30:19 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None 
 ```

```
# kubectl get all
NAME                                             READY   STATUS    RESTARTS   AGE
pod/myapp-multitool-deployment-6ffd9b476-r7d8z   1/1     Running   0          39s
pod/myapp-nginx-deployment-59647f496c-ds2tr      1/1     Running   0          39s

NAME                          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service/myapp-multitool-svc   ClusterIP   10.152.183.145   <none>        80/TCP    40s
service/myapp-nginx-svc       ClusterIP   10.152.183.216   <none>        80/TCP    40s

NAME                                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/depl1-depl                   1/1     1            1           106d
deployment.apps/depl2-depl                   1/1     1            1           106d
deployment.apps/myapp-multitool-deployment   1/1     1            1           39s
deployment.apps/myapp-nginx-deployment       1/1     1            1           39s

NAME                                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/myapp-multitool-deployment-6ffd9b476   1         1         1       39s
replicaset.apps/myapp-nginx-deployment-59647f496c      1         1         1       39s
```

2. Одну версию в namespace=app1, вторую версию в том же неймспейсе, третью версию в namespace=app2.
3. Продемонстрируйте результат.


```
# kubectl create namespace app1
namespace/app1 created
# kubectl create namespace app2
namespace/app2 created
```

```
# helm install myapp myapp --namespace=app1
NAME: myapp
LAST DEPLOYED: Thu Mar 14 17:32:37 2024
NAMESPACE: app1
STATUS: deployed
REVISION: 1
TEST SUITE: None

# helm install myapp2 myapp --namespace=app1 -f myapp/values2.yaml
NAME: myapp2
LAST DEPLOYED: Thu Mar 14 17:32:49 2024
NAMESPACE: app1
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

```
# kubectl get all -o wide -n app1

NAME                                               READY   STATUS    RESTARTS   AGE   IP             NODE          NOMINATED NODE   READINESS GATES
pod/myapp-multitool-deployment-6ffd9b476-ljx2q     1/1     Running   0          79s   10.1.196.175   kub.nobr.ru   <none>           <none>
pod/myapp-nginx-deployment-59647f496c-zsvdk        1/1     Running   0          79s   10.1.196.152   kub.nobr.ru   <none>           <none>
pod/myapp2-nginx-deployment-78bf58d564-lvbpf       1/1     Running   0          68s   10.1.196.179   kub.nobr.ru   <none>           <none>
pod/myapp2-multitool-deployment-666c9cbdb8-wwhbc   1/1     Running   0          68s   10.1.196.184   kub.nobr.ru   <none>           <none>

NAME                           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service/myapp-multitool-svc    ClusterIP   10.152.183.20    <none>        80/TCP    80s   app=myapp-multitool
service/myapp-nginx-svc        ClusterIP   10.152.183.240   <none>        80/TCP    80s   app=myapp-nginx
service/myapp2-multitool-svc   ClusterIP   10.152.183.35    <none>        80/TCP    68s   app=myapp-multitool
service/myapp2-nginx-svc       ClusterIP   10.152.183.122   <none>        80/TCP    68s   app=myapp-nginx

NAME                                          READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS         IMAGES                                   SELECTOR
deployment.apps/myapp-multitool-deployment    1/1     1            1           79s   myapp-multitool    wbitt/network-multitool:alpine-minimal   app=myapp-multitool
deployment.apps/myapp-nginx-deployment        1/1     1            1           79s   myapp-nginx        nginx:1.24                               app=myapp-nginx
deployment.apps/myapp2-nginx-deployment       1/1     1            1           68s   myapp2-nginx       nginx:1.25                               app=myapp-nginx
deployment.apps/myapp2-multitool-deployment   1/1     1            1           68s   myapp2-multitool   wbitt/network-multitool:latest           app=myapp-multitool

NAME                                                     DESIRED   CURRENT   READY   AGE   CONTAINERS         IMAGES                                   SELECTOR
replicaset.apps/myapp-multitool-deployment-6ffd9b476     1         1         1       79s   myapp-multitool    wbitt/network-multitool:alpine-minimal   app=myapp-multitool,pod-template-hash=6ffd9b476
replicaset.apps/myapp-nginx-deployment-59647f496c        1         1         1       79s   myapp-nginx        nginx:1.24                               app=myapp-nginx,pod-template-hash=59647f496c
replicaset.apps/myapp2-nginx-deployment-78bf58d564       1         1         1       68s   myapp2-nginx       nginx:1.25                               app=myapp-nginx,pod-template-hash=78bf58d564
replicaset.apps/myapp2-multitool-deployment-666c9cbdb8   1         1         1       68s   myapp2-multitool   wbitt/network-multitool:latest           app=myapp-multitool,pod-template-hash=666c9cbdb8
```

```
# helm install myapp myapp --namespace=app2 --set nginx_version.tag="1.23",multitool_version.tag="alpine-extra"

NAME: myapp
LAST DEPLOYED: Thu Mar 14 17:35:50 2024
NAMESPACE: app2
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

```
# kubectl get all -o wide -n app2

NAME                                              READY   STATUS    RESTARTS   AGE   IP             NODE          NOMINATED NODE   READINESS GATES
pod/myapp-multitool-deployment-6ff575d787-pgx96   1/1     Running   0          53s   10.1.196.187   kub.nobr.ru   <none>           <none>
pod/myapp-nginx-deployment-d9bffc44-zgtdr         1/1     Running   0          53s   10.1.196.174   kub.nobr.ru   <none>           <none>

NAME                          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service/myapp-nginx-svc       ClusterIP   10.152.183.74    <none>        80/TCP    54s   app=myapp-nginx
service/myapp-multitool-svc   ClusterIP   10.152.183.150   <none>        80/TCP    54s   app=myapp-multitool

NAME                                         READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS        IMAGES                                 SELECTOR
deployment.apps/myapp-multitool-deployment   1/1     1            1           54s   myapp-multitool   wbitt/network-multitool:alpine-extra   app=myapp-multitool
deployment.apps/myapp-nginx-deployment       1/1     1            1           54s   myapp-nginx       nginx:1.23                             app=myapp-nginx

NAME                                                    DESIRED   CURRENT   READY   AGE   CONTAINERS        IMAGES                                 SELECTOR
replicaset.apps/myapp-multitool-deployment-6ff575d787   1         1         1       54s   myapp-multitool   wbitt/network-multitool:alpine-extra   app=myapp-multitool,pod-template-hash=6ff575d787
replicaset.apps/myapp-nginx-deployment-d9bffc44         1         1         1       54s   myapp-nginx       nginx:1.23                             app=myapp-nginx,pod-template-hash=d9bffc44
```

```
# helm upgrade myapp myapp --namespace=app1 -f myapp/values2.yaml

Release "myapp" has been upgraded. Happy Helming!
NAME: myapp
LAST DEPLOYED: Thu Mar 14 17:38:28 2024
NAMESPACE: app1
STATUS: deployed
REVISION: 2
TEST SUITE: None

~# kubectl get all -o wide -n app1
NAME                                               READY   STATUS    RESTARTS   AGE    IP             NODE          NOMINATED NODE   READINESS GATES
pod/myapp2-nginx-deployment-78bf58d564-lvbpf       1/1     Running   0          6m5s   10.1.196.179   kub.nobr.ru   <none>           <none>
pod/myapp2-multitool-deployment-666c9cbdb8-wwhbc   1/1     Running   0          6m5s   10.1.196.184   kub.nobr.ru   <none>           <none>
pod/myapp-nginx-deployment-6fbc479bf8-tnclr        1/1     Running   0          25s    10.1.196.189   kub.nobr.ru   <none>           <none>
pod/myapp-multitool-deployment-5fb59978db-nbrx8    1/1     Running   0          25s    10.1.196.158   kub.nobr.ru   <none>           <none>

NAME                           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE     SELECTOR
service/myapp-multitool-svc    ClusterIP   10.152.183.20    <none>        80/TCP    6m17s   app=myapp-multitool
service/myapp-nginx-svc        ClusterIP   10.152.183.240   <none>        80/TCP    6m17s   app=myapp-nginx
service/myapp2-multitool-svc   ClusterIP   10.152.183.35    <none>        80/TCP    6m5s    app=myapp-multitool
service/myapp2-nginx-svc       ClusterIP   10.152.183.122   <none>        80/TCP    6m5s    app=myapp-nginx

NAME                                          READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS         IMAGES                           SELECTOR
deployment.apps/myapp2-nginx-deployment       1/1     1            1           6m5s    myapp2-nginx       nginx:1.25                       app=myapp-nginx
deployment.apps/myapp2-multitool-deployment   1/1     1            1           6m5s    myapp2-multitool   wbitt/network-multitool:latest   app=myapp-multitool
deployment.apps/myapp-multitool-deployment    1/1     1            1           6m16s   myapp-multitool    wbitt/network-multitool:latest   app=myapp-multitool
deployment.apps/myapp-nginx-deployment        1/1     1            1           6m16s   myapp-nginx        nginx:1.25                       app=myapp-nginx
```

------