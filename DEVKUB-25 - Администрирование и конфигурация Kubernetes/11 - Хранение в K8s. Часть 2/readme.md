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


1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Создать PV и PVC для подключения папки на локальной ноде, которая будет использована в поде.

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

3. Продемонстрировать, что multitool может читать файл, в который busybox пишет каждые пять секунд в общей директории.
   
```
# kubectl exec pod/deployment1-699cf9cff8-27q5c -c multitool -- cat /input/output.txt

message from busybox!
message from busybox!
message from busybox!
message from busybox!
message from busybox!
message from busybox!
message from busybox!
message from busybox!
message from busybox!
message from busybox!
```


4. Удалить Deployment и PVC. Продемонстрировать, что после этого произошло с PV. Пояснить, почему.

```
# kubectl delete deployments.apps deployment1
deployment.apps "deployment1" deleted
```

```
# kubectl get pvc
NAME   STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc1   Bound    pv1      1Gi        RWO            host-path      9d
```

```
#  kubectl delete pvc pvc1
persistentvolumeclaim "pvc1" deleted
```

```
# kubectl get all,pv,pvc
NAME                   CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM       STORAGECLASS   REASON   AGE
persistentvolume/pv1   1Gi        RWO            Retain           Released   hw11/pvc1   host-path               9d
```

После удаления PersistentVolumeClaim, PersistentVolume остаётся и отмечается "released". Он будет недоступен для новых PersistentVolumeClaim, т.к. содержит данные предыдущего PersistentVolumeClaim.

5. Продемонстрировать, что файл сохранился на локальном диске ноды. Удалить PV Продемонстрировать что произошло с файлом после удаления PV. Пояснить, почему.

```
# ls -la /data1/pv1/
total 3612
drwxr-xr-x 2 root root    4096 Nov  5 00:48 .
drwxr-xr-x 3 root root    4096 Nov  5 00:48 ..
-rw-r--r-- 1 root root 3684670 Nov 14 17:26 output.txt
```

```
# kubectl describe pv pv1
Name:            pv1
Labels:          <none>
Annotations:     pv.kubernetes.io/bound-by-controller: yes
Finalizers:      [kubernetes.io/pv-protection]
StorageClass:    host-path
Status:          Released
Claim:           hw11/pvc1
Reclaim Policy:  Retain
Access Modes:    RWO
VolumeMode:      Filesystem
Capacity:        1Gi
Node Affinity:   <none>
Message:
Source:
    Type:          HostPath (bare host directory volume)
    Path:          /data1/pv1
    HostPathType:
Events:            <none>
```

```
#  kubectl delete pv pv1
persistentvolume "pv1" deleted
```

```
# ls -la /data1/pv1/
total 3612
drwxr-xr-x 2 root root    4096 Nov  5 00:48 .
drwxr-xr-x 3 root root    4096 Nov  5 00:48 ..
-rw-r--r-- 1 root root 3684670 Nov 14 17:26 output.txt
```

Политика Reclaim Policy: Retain говорит, что после удаления PV ресурсы из внешних провайдеров автоматически не удаляются, однако при действии Delete, после удаления PV ресурсы удаляются только из облачных Storage. Файл остается.

[манифест](dep1.yml)

------

### Задание 2

**Что нужно сделать**

Создать Deployment приложения, которое может хранить файлы на NFS с динамическим созданием PV.

1. Включить и настроить NFS-сервер на MicroK8S.
2. Создать Deployment приложения состоящего из multitool, и подключить к нему PV, созданный автоматически на сервере NFS.
3. Продемонстрировать возможность чтения и записи файла изнутри пода. 
4. Предоставить манифесты, а также скриншоты или вывод необходимых команд.


#### Ответ на задание 2

1. Включить и настроить NFS-сервер на MicroK8S.

```
#  microk8s enable nfs
Addon nfs was not found in any repository
```

Получили ошибку, сначала нужно поставить community

```
# microk8s enable community
Infer repository core for addon community
Cloning into '/var/snap/microk8s/common/addons/community'...
done.
Community repository is now enabled
```

```
# microk8s enable nfs
Infer repository community for addon nfs
Infer repository core for addon helm3
Addon core/helm3 is already enabled
Installing NFS Server Provisioner - Helm Chart 1.4.0

Node Name not defined. NFS Server Provisioner will be deployed on random Microk8s Node.

If you want to use a dedicated (large disk space) Node as NFS Server, disable the Addon and start over: microk8s enable nfs -n NODE_NAME
Lookup Microk8s Node name as: kubectl get node -o yaml | grep 'kubernetes.io/hostname'

Preparing PV for NFS Server Provisioner

persistentvolume/data-nfs-server-provisioner-0 created
"nfs-ganesha-server-and-external-provisioner" has been added to your repositories
Release "nfs-server-provisioner" does not exist. Installing it now.
NAME: nfs-server-provisioner
LAST DEPLOYED: Tue Nov 14 17:33:41 2023
NAMESPACE: nfs-server-provisioner
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The NFS Provisioner service has now been installed.

A storage class named 'nfs' has now been created
and is available to provision dynamic volumes.

You can use this storageclass by creating a `PersistentVolumeClaim` with the
correct storageClassName attribute. For example:

    ---
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: test-dynamic-volume-claim
    spec:
      storageClassName: "nfs"
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 100Mi

NFS Server Provisioner is installed

WARNING: Install "nfs-common" package on all MicroK8S nodes to allow Pods with NFS mounts to start: sudo apt update && sudo apt install -y nfs-common
WARNING: NFS Server Provisioner servers by default hostPath storage from a single Node.
```

```
# kubectl get storageclasses.storage.k8s.io
NAME   PROVISIONER                            RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs    cluster.local/nfs-server-provisioner   Delete          Immediate           true                   113s
```

2. Создать Deployment приложения состоящего из multitool, и подключить к нему PV, созданный автоматически на сервере NFS.

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment2
  labels:
    app: depl2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: depl2
  template:
    metadata:
      labels:
        app: depl2
    spec:
      containers:

      - name: multitool
        image: wbitt/network-multitool:latest
        ports:
        - containerPort: 80
        env:
        - name: HTTP_PORT
          value: "80"
        volumeMounts:
        - name: pv2
          mountPath: /input

      volumes:
      - name: pv2
        persistentVolumeClaim:
          claimName: pvc1

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc1
spec:
  storageClassName: "nfs"
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

```
# kubectl apply -f hw11-dep2.yml
deployment.apps/deployment2 created
persistentvolumeclaim/pvc1 created
```

```
# kubectl get all,pv,pvc
NAME                               READY   STATUS    RESTARTS   AGE
pod/deployment2-64bb56d876-fxs77   1/1     Running   0          53s

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/deployment2   1/1     1            1           53s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/deployment2-64bb56d876   1         1         1       53s

NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM
                           STORAGECLASS   REASON   AGE
persistentvolume/data-nfs-server-provisioner-0              1Gi        RWO            Retain           Bound    nfs-server-provisioner/data-nfs-server-provisioner-0                           5m39s
persistentvolume/pvc-0d691ad9-cf87-40ad-a565-3641f2e554e3   1Gi        RWO            Delete           Bound    hw11/pvc1
                           nfs                     52s

NAME                         STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/pvc1   Bound    pvc-0d691ad9-cf87-40ad-a565-3641f2e554e3   1Gi        RWO            nfs            53s
```

3. Продемонстрировать возможность чтения и записи файла изнутри пода. 

```
# kubectl exec deployment.apps/deployment2 -it -- bash

deployment2-64bb56d876-fxs77:/# cd input/
deployment2-64bb56d876-fxs77:/input# ls
deployment2-64bb56d876-fxs77:/input# vi test.txt

deployment2-64bb56d876-fxs77:/input# cat test.txt
this is test
```

```
# cat /var/snap/microk8s/common/nfs-storage/pvc-0d691ad9-cf87-40ad-a565-3641f2e554e3/test.txt
this is test
```

4. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

[манифест](dep2.yml)

------
