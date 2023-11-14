# Домашнее задание к занятию «Хранение в K8s. Часть 2»

### Цель задания

В тестовой среде Kubernetes нужно создать PV и продемострировать запись и хранение файлов.

------

### Задание 1

**Что нужно сделать**

Создать Deployment приложения, использующего локальный PV, созданный вручную.

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Создать PV и PVC для подключения папки на локальной ноде, которая будет использована в поде.
3. Продемонстрировать, что multitool может читать файл, в который busybox пишет каждые пять секунд в общей директории. 
4. Удалить Deployment и PVC. Продемонстрировать, что после этого произошло с PV. Пояснить, почему.
5. Продемонстрировать, что файл сохранился на локальном диске ноды. Удалить PV.  Продемонстрировать что произошло с файлом после удаления PV. Пояснить, почему.
5. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

#### Ответ на задание 1

```
kubectl create ns hw11

kubectl config set-context --current --namespace=hw11
```

```
# kubectl create ns hw11
namespace/hw11 created
# kubectl config set-context --current --namespace=hw11
Context "microk8s" modified.
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
        command: ['sh', '-c', 'while true; do echo message from busybox! >> /output/output.txt; sleep 5; done']
        volumeMounts:
        - name: pv1
          mountPath: /output

      - name: multitool
        image: wbitt/network-multitool:latest
        ports:
        - containerPort: 80
        env:
        - name: HTTP_PORT
          value: "80"
        volumeMounts:
        - name: pv1
          mountPath: /input

      volumes:
      - name: pv1
        persistentVolumeClaim:
          claimName: pvc1

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv1
spec:
  storageClassName: host-path
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  hostPath:
    path: /data1/pv1

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc1
spec:
  storageClassName: host-path
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

```
# kubectl apply -f hw11-dep1.yml
deployment.apps/deployment1 created
persistentvolume/pv1 created
persistentvolumeclaim/pvc1 created
```

```
# kubectl get all
NAME                               READY   STATUS    RESTARTS   AGE
pod/deployment1-699cf9cff8-27q5c   2/2     Running   0          3m38s

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/deployment1   1/1     1            1           3m38s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/deployment1-699cf9cff8   1         1         1       3m38s
```

```

```


------

### Задание 2

**Что нужно сделать**

Создать Deployment приложения, которое может хранить файлы на NFS с динамическим созданием PV.

1. Включить и настроить NFS-сервер на MicroK8S.
2. Создать Deployment приложения состоящего из multitool, и подключить к нему PV, созданный автоматически на сервере NFS.
3. Продемонстрировать возможность чтения и записи файла изнутри пода. 
4. Предоставить манифесты, а также скриншоты или вывод необходимых команд.


#### Ответ на задание 2



------
