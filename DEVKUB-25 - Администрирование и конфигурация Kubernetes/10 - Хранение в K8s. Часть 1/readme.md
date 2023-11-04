# Домашнее задание к занятию «Хранение в K8s. Часть 1»

### Цель задания

В тестовой среде Kubernetes нужно обеспечить обмен файлами между контейнерам пода и доступ к логам ноды.

------

### Задание 1 

**Что нужно сделать**

Создать Deployment приложения, состоящего из двух контейнеров и обменивающихся данными.

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Сделать так, чтобы busybox писал каждые пять секунд в некий файл в общей директории.
3. Обеспечить возможность чтения файла контейнером multitool.
4. Продемонстрировать, что multitool может читать файл, который периодоически обновляется.
5. Предоставить манифесты Deployment в решении, а также скриншоты или вывод команды из п. 4.

#### Ответ на задание 1

```
kubectl create ns hw10

kubectl config set-context --current --namespace=hw10
```

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment1
  labels:
    app: dep1
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
      - name: busybox
        image: busybox
        command: ['sh', '-c', 'while true; do echo busybox message! >> /output/output.txt; sleep 5; done']
        volumeMounts:
        - name: dep1-volume
          mountPath: /output
      - name: multitool
        image: wbitt/network-multitool:latest
        ports:
        - containerPort: 80
        env:
        - name: HTTP_PORT
          value: "80"
        volumeMounts:
        - name: dep1-volume
          mountPath: /input
      volumes:
      - name: dep1-volume
        emptyDir: {}
```

```
# kubectl apply -f hw10-dep1.yml
deployment.apps/deployment1 created
```

```
# kubectl get deployments,pods
NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/deployment1   1/1     1            1           55s

NAME                               READY   STATUS    RESTARTS   AGE
pod/deployment1-5dd755c8c9-tk544   2/2     Running   0          54s
```

```
#  kubectl exec pod/deployment1-5dd755c8c9-tk544 -c busybox -- tail -f /output/output.txt
busybox message!
busybox message!
busybox message!
```

```
# kubectl exec pod/deployment1-5dd755c8c9-tk544 -c multitool -- cat /input/output.txt
busybox message!
busybox message!
busybox message!
```

[dep1.yml](dep1.yml)

------

### Задание 2

**Что нужно сделать**

Создать DaemonSet приложения, которое может прочитать логи ноды.

1. Создать DaemonSet приложения, состоящего из multitool.
2. Обеспечить возможность чтения файла `/var/log/syslog` кластера MicroK8S.
3. Продемонстрировать возможность чтения файла изнутри пода.
4. Предоставить манифесты Deployment, а также скриншоты или вывод команды из п. 2.


#### Ответ на задание 2

```
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: deployment2
  labels:
    app: dep1
spec:
  selector:
    matchLabels:
      app: dep1
  template:
    metadata:
      labels:
        app: dep1
    spec:
      containers:
      - name: multitool
        image: wbitt/network-multitool
        volumeMounts:
        - name: varlog
          mountPath: /output
        ports:
        ports:
        - containerPort: 80
        env:
        - name: HTTP_PORT
          value: "80"
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
```

```
# kubectl apply -f hw10-dep2.yml
daemonset.apps/deployment2 created
```

```
# kubectl get deployments,pods
NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/deployment1   1/1     1            1           10m

NAME                               READY   STATUS    RESTARTS   AGE
pod/deployment1-5dd755c8c9-tk544   2/2     Running   0          10m
pod/deployment2-d7cxr              1/1     Running   0          87s
```

```
#  kubectl exec pods/deployment2-d7cxr -c multitool -- tail -10 /output/syslog
Nov  5 00:39:45 kub systemd[1]: run-containerd-runc-k8s.io-2199a04f01a09384a4a80a9e7242ec0f4cc98fa290ee9396ff4d149c7871ee7a-runc.SSOR6Q.mount: Deactivated successfully.
Nov  5 00:39:52 kub systemd[1]: run-containerd-runc-k8s.io-2bd699a0b43208ab20853c36314b6a47079c66ea69e0c4971e5c21cd8499f5f8-runc.vun3XO.mount: Deactivated successfully.
Nov  5 00:39:53 kub systemd[1]: run-containerd-runc-k8s.io-2bd699a0b43208ab20853c36314b6a47079c66ea69e0c4971e5c21cd8499f5f8-runc.Ltsmuk.mount: Deactivated successfully.
Nov  5 00:39:55 kub systemd[1]: run-containerd-runc-k8s.io-2199a04f01a09384a4a80a9e7242ec0f4cc98fa290ee9396ff4d149c7871ee7a-runc.JXQn74.mount: Deactivated successfully.
Nov  5 00:39:55 kub systemd[1]: run-containerd-runc-k8s.io-2199a04f01a09384a4a80a9e7242ec0f4cc98fa290ee9396ff4d149c7871ee7a-runc.6tDRMw.mount: Deactivated successfully.
Nov  5 00:40:02 kub systemd[1]: run-containerd-runc-k8s.io-2bd699a0b43208ab20853c36314b6a47079c66ea69e0c4971e5c21cd8499f5f8-runc.bQ1ohc.mount: Deactivated successfully.
Nov  5 00:40:02 kub systemd[1]: run-containerd-runc-k8s.io-2bd699a0b43208ab20853c36314b6a47079c66ea69e0c4971e5c21cd8499f5f8-runc.qCtIcC.mount: Deactivated successfully.
Nov  5 00:40:05 kub systemd[1]: run-containerd-runc-k8s.io-2199a04f01a09384a4a80a9e7242ec0f4cc98fa290ee9396ff4d149c7871ee7a-runc.PWAyMV.mount: Deactivated successfully.
Nov  5 00:40:12 kub systemd[1]: run-containerd-runc-k8s.io-2bd699a0b43208ab20853c36314b6a47079c66ea69e0c4971e5c21cd8499f5f8-runc.T2V831.mount: Deactivated successfully.
Nov  5 00:40:12 kub systemd[1]: run-containerd-runc-k8s.io-2bd699a0b43208ab20853c36314b6a47079c66ea69e0c4971e5c21cd8499f5f8-runc.pF2wHB.mount: Deactivated successfully.
```


[dep2.yml](dep2.yml)

------