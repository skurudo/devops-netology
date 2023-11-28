# Домашнее задание к занятию «Конфигурация приложений»

### Цель задания

В тестовой среде Kubernetes необходимо создать конфигурацию и продемонстрировать работу приложения.

------

### Задание 1. Создать Deployment приложения и решить возникшую проблему с помощью ConfigMap. Добавить веб-страницу

1. Создать Deployment приложения, состоящего из контейнеров nginx и multitool.
2. Решить возникшую проблему с помощью ConfigMap.
3. Продемонстрировать, что pod стартовал и оба конейнера работают.
4. Сделать простую веб-страницу и подключить её к Nginx с помощью ConfigMap. Подключить Service и показать вывод curl или в браузере.
5. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

#### Ответ на задание 1

1. Создать Deployment приложения, состоящего из контейнеров nginx и multitool.
2. Решить возникшую проблему с помощью ConfigMap.

```
kubectl create ns hw12

kubectl config set-context --current --namespace=hw12
```

```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: multitool-dep
  name: multitool-dep
  namespace: hw12
spec:
  replicas: 1
  selector:
    matchLabels:
      app: multitool
  template:
    metadata:
      labels:
        app: multitool
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
      - name: multitool
        image: wbitt/network-multitool:latest
        ports:
        - containerPort: 8080
        env:
        - name: HTTP_PORT
          valueFrom:
            configMapKeyRef:
              name: dep1-cfgmap
              key: http-port
        - name: HTTPS_PORT
          valueFrom:
            configMapKeyRef:
              name: dep1-cfgmap
              key: https-port
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: dep1-cfgmap
data:
  http-port: "8080"
  https-port: "11443"
```


3. Продемонстрировать, что pod стартовал и оба конейнера работают.

```
# kubectl apply -f hw12-dep1.yml

# kubectl get pods
NAME                             READY   STATUS    RESTARTS      AGE
multitool-dep-64f4f99488-tr9z6   2/2     Running   2 (86s ago)   4m36s
```

4. Сделать простую веб-страницу и подключить её к Nginx с помощью ConfigMap. Подключить Service и показать вывод curl или в браузере.

```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: dep1
  name: dep1-depl
  namespace: hw12
spec:
  replicas: 1
  selector:
    matchLabels:
      app: dep1
  template:
    metadata:
      labels:
        app: dep1
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        volumeMounts:
        - name: dep1-html-vol
          mountPath: /usr/share/nginx/html
      - name: multitool
        image: wbitt/network-multitool:latest
        ports:
        - containerPort: 8080
        env:
        - name: HTTP_PORT
          valueFrom:
            configMapKeyRef:
              name: dep1-cfgmap
              key: http-port
        - name: HTTPS_PORT
          valueFrom:
            configMapKeyRef:
              name: dep1-cfgmap
              key: https-port
      volumes:
      - name: dep1-html-vol
        configMap:
          name: dep1-cgfmap-html

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: dep1-cfgmap
data:
  http-port: "8080"
  https-port: "11443"

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: dep1-cgfmap-html
data:
  index.html: |
    <html>
      <body>
        <h1>Nginx here and there.</h1>
      </body>
    </html>

---
apiVersion: v1
kind: Service
metadata:
  name: dep1-svc
spec:
  selector:
    app: dep1
  ports:
  - name: dep1-nginx-svc-port
    port: 80
    targetPort: 80
```

```
# kubectl apply -f hw12-dep1-2.yml
deployment.apps/dep1-depl created
configmap/dep1-cfgmap unchanged
configmap/dep1-cgfmap-html created
service/dep1-svc created
```

```
# microk8s kubectl port-forward services/dep1-svc 3000:80 --address="0.0.0.0"
Forwarding from 0.0.0.0:3000 -> 80
```

```
# kubectl get pods,service
NAME                              READY   STATUS    RESTARTS   AGE
pod/dep1-depl-599d5b84cd-cm624   2/2     Running   0          4m9s

NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.152.183.1     <none>        443/TCP   4m42s
service/dep1-svc     ClusterIP   10.152.183.171   <none>        80/TCP    4m9s
```

```
# curl -k 10.152.183.171
<html>
  <body>
    <h1>Hello, I am nginx.</h1>
  </body>
</html>
```


5. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

* [dep1.yml](dep1.yml)
* [dep1-2.yml](dep1-2.yml)

------

### Задание 2. Создать приложение с вашей веб-страницей, доступной по HTTPS 

1. Создать Deployment приложения, состоящего из Nginx.
2. Создать собственную веб-страницу и подключить её как ConfigMap к приложению.
3. Выпустить самоподписной сертификат SSL. Создать Secret для использования сертификата.

```
# openssl req -x509 -nodes -days 365 -newkey rsa:4096 -sha256 -keyout selfsigned.key -out selfsigned.crt -subj "/C=RU/ST=MSK/L=MSK/O=WWWA/OU=Org/CN=kub.nobr.local"
...+......+.......+............+.....+...+..................+......+.+..+.+..+....+...+........+...+.........+.+.....+.+......+...+............+...+.....+....+...............+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*....+......+.....+...+....+........+...+....+......+..+..........+.....+.......+..+....+..............+.+..+.........+...+.+...............+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*.....+...+..................+....+...+.........+....................+......+...............+...+.......+...+...........+...................+......+........+......+....+..+...+..................+....+.....+...+...+....+......+.....+.........+...+..........+...............+...+..+............+.+........+.+.....+.........+................+.........+..+............+.+...............+..+...+....+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
..........+.....+......+.+...+....................+.+.........+............+...+............+..+...+.........+.+..+...+....+.....+....+.........+.....+.+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*.....+.........+...+.+..+.......+...+..+...+....+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*....+......+.........................+........+...+.......+......+.....+..........+............+............+...+.....+............+...+.......+...........+........................+.+....................+....+...+.....+........................+.+............+..+.........+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-----
```
4. Создать Ingress и необходимый Service, подключить к нему SSL в вид. Продемонстировать доступ к приложению по HTTPS. 

```
base64 selfsigned.key
base64 selfsigned.crt

kubectl apply -f hw12-dep2.yml
```

```
# curl -k https://kub.nobr.local
<html>
  <body>
    <h1>Hello, I am nginx with SSL.</h1>
  </body>
</html>
```

```
# wget --no-check-certificate https://kub.nobr.local
Resolving kub.nobr.local (kub.nobr.local)... 127.0.0.1
Connecting to kub.nobr.local (kub.nobr.local)|127.0.0.1|:443... connected.
WARNING: cannot verify kub.nobr.local's certificate, issued by ‘CN=Kubernetes Ingress Controller Fake Certificate,O=Acme Co’:
  Self-signed certificate encountered.
WARNING: no certificate subject alternative name matches
        requested host name ‘kub.nobr.local’.
HTTP request sent, awaiting response... 200 OK
Length: 75 [text/html]
Saving to: ‘index.html’

index.html                                     100%[=================================================================================================>]      75  --.-KB/s    in 0s

(2.16 MB/s) - ‘index.html’ saved [75/75]

root@kub:~# cat index.html
<html>
  <body>
    <h1>Hello, I am nginx with SSL.</h1>
  </body>
</html>
```

5. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

* [dep2.yml](dep2.yml)

#### Ответ на задание 2
------

