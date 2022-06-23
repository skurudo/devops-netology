# Домашнее задание к занятию "3.5. Файловые системы"

## 1. Узнайте о sparse (разряженных) файлах.

Разрежённый файл (англ. sparse file) — файл, в котором последовательности нулевых байтов заменены на информацию об этих последовательностях (список дыр).. занимательно! Становится более понятно, почему BTRFS/ZFS/ReiserFS их поддерживают - экономия пространства и скорость (запись нулей ничего не стоит).. а также понятно, почему оно может нестабильно работать - не записал в таблицу, из-за увеличения накладных расходов на работу со списком - гарантировано получи приключения.

## 2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?

Нет, не могут. Жесткая ссылка - это не софт ссылка или ярлык, это по сути тот же файл, на который ссылается. У жесткой ссылки тайкой же inode, что и оригинальный файл, аналогичные права и тот же владелец - набор атрибутов. По-другому быть не может.

Жесткая ссылка это по сути зеркальная копия объекта, наследующая его права, владельца и группу. Имеет тот же inode что и оригинальный файл.
Поэтому разных владельцев и разные права оригинал и хардлинк иметь не могут.


## 3. Сделайте vagrant destroy на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:

По согласованию с сенсеем, сделали другую виртуальную машину:
- mkdir dev2
- vagrant init
- nano Vagrantfile
- vagrant up

> Vagrant.configure("2") do |config|
>   config.vm.box = "bento/ubuntu-20.04"
>   config.vm.provider :virtualbox do |vb| -- здесь меняем на vmware, т.к. другой провайдер
>     lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
>     lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
>     vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
>     vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
>     vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
>     vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
> end
> end

- конфиг привелик такому состоянию:
> Vagrant.configure("2") do |config|
>   config.vm.box = "bento/ubuntu-20.04"
>   config.vm.provider :vmware do |vm|
>     lvm_experiments_disk0_path = "C:/Users/skuru/Documents/dev2/tmp/lvm_experiments_disk0.vmdk"
>     lvm_experiments_disk1_path = "C:/Users/skuru/Documents/dev2/tmp/lvm_experiments_disk1.vmdk"
>     vm.vmx ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
>     vm.vmx ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
>     vm.vmx ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 5, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
>     vm.vmx ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 6, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
>   end
> end

- vagrant ssh
- но в случае с VMWare не вышло сделать то, что нужно - система стартует, но не дает дисков по заданию.. 
- для экономии времени пришлось пересесть обратно в Virtualbox, где конструкция запустилась без плясок:

vagrant@vagrant:~$ sudo fdisk -l | grep Disk
Disk /dev/loop0: 55.45 MiB, 58130432 bytes, 113536 sectors
Disk /dev/loop1: 32.3 MiB, 33865728 bytes, 66144 sectors
Disk /dev/loop2: 70.32 MiB, 73728000 bytes, 144000 sectors
Disk /dev/loop3: 43.6 MiB, 45703168 bytes, 89264 sectors
Disk /dev/loop4: 55.52 MiB, 58204160 bytes, 113680 sectors
Disk /dev/loop5: 61.93 MiB, 64917504 bytes, 126792 sectors
Disk /dev/loop6: 67.25 MiB, 70508544 bytes, 137712 sectors
Disk /dev/sda: 64 GiB, 68719476736 bytes, 134217728 sectors
Disk model: VBOX HARDDISK
Disklabel type: gpt
Disk identifier: B4F1CD46-1589-455C-BA21-5171874A019C
Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Disk /dev/mapper/ubuntu--vg-ubuntu--lv: 31.51 GiB, 33822867456 bytes, 66060288 sectors

или

vagrant@vagrant:~$ lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
loop0                       7:0    0 55.4M  1 loop /snap/core18/2128
loop2                       7:2    0 70.3M  1 loop /snap/lxd/21029
loop3                       7:3    0 43.6M  1 loop /snap/snapd/14978
loop4                       7:4    0 55.5M  1 loop /snap/core18/2284
loop5                       7:5    0 61.9M  1 loop /snap/core20/1328
loop6                       7:6    0 67.2M  1 loop /snap/lxd/21835
sda                         8:0    0   64G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0    1G  0 part /boot
└─sda3                      8:3    0   63G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.5G  0 lvm  /
sdb                         8:16   0  2.5G  0 disk
sdc                         8:32   0  2.5G  0 disk

## 4. Используя fdisk, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.

sudo fdisk /dev/sdb
m - help
Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p

Partition number (1-4, default 1):1
First sector (2048-5242879, default 2048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-5242879, default 5242879): +2G
Created a new partition 1 of type 'Linux' and of size 2 GiB.

Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (2-4, default 2):
First sector (4196352-5242879, default 4196352):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-5242879, default 5242879):
Created a new partition 2 of type 'Linux' and of size 511 MiB.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

vagrant@vagrant:~$ sudo fdisk -l /dev/sdb
Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x7ef112f4

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdb1          2048 4196351 4194304    2G 83 Linux
/dev/sdb2       4196352 5242879 1046528  511M 83 Linux


## 5. Используя sfdisk, перенесите данную таблицу разделов на второй диск.
vagrant@vagrant:~# sudo sfdisk -d /dev/sdb | sudo sfdisk /dev/sdc

vagrant@vagrant:~# sudo fdisk -l /dev/sdc
Disk /dev/sda: 64 GiB, 68719476736 bytes, 134217728 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x7ef112f4

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdc1          2048 4196351 4194304    2G 83 Linux
/dev/sdc2       4196352 5242879 1046528  511M 83 Linux

## 6. Соберите mdadm RAID1 на паре разделов 2 Гб.

vagrant@vagrant:~$ sudo mdadm --create --verbose /dev/md0 -l 1 -n 2 /dev/sd{b1,c1}
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
mdadm: size set to 2094080K
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.

vagrant@vagrant:~$ lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
loop1                       7:1    0 70.3M  1 loop  /snap/lxd/21029
loop2                       7:2    0 55.4M  1 loop  /snap/core18/2128
loop3                       7:3    0 55.5M  1 loop  /snap/core18/2284
loop4                       7:4    0 43.6M  1 loop  /snap/snapd/14978
loop5                       7:5    0 61.9M  1 loop  /snap/core20/1328
loop6                       7:6    0 67.2M  1 loop  /snap/lxd/21835
sda                         8:0    0   64G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0    1G  0 part  /boot
└─sda3                      8:3    0   63G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.5G  0 lvm   /
sdb                         8:16   0  2.5G  0 disk
├─sdb1                      8:17   0    2G  0 part
│ └─md0                     9:0    0    2G  0 raid1
└─sdb2                      8:18   0  511M  0 part
sdc                         8:32   0  2.5G  0 disk
├─sdc1                      8:33   0    2G  0 part
│ └─md0                     9:0    0    2G  0 raid1
└─sdc2                      8:34   0  511M  0 part

## 7. Соберите mdadm RAID0 на второй паре маленьких разделов.

vagrant@vagrant:~$ sudo mdadm --create --verbose /dev/md1 -l 0 -n 2 /dev/sd{b2,c2}
mdadm: chunk size defaults to 512K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md1 started.

vagrant@vagrant:~$ lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
loop1                       7:1    0 70.3M  1 loop  /snap/lxd/21029
loop2                       7:2    0 55.4M  1 loop  /snap/core18/2128
loop3                       7:3    0 55.5M  1 loop  /snap/core18/2284
loop4                       7:4    0 43.6M  1 loop  /snap/snapd/14978
loop5                       7:5    0 61.9M  1 loop  /snap/core20/1328
loop6                       7:6    0 67.2M  1 loop  /snap/lxd/21835
sda                         8:0    0   64G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0    1G  0 part  /boot
└─sda3                      8:3    0   63G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.5G  0 lvm   /
sdb                         8:16   0  2.5G  0 disk
├─sdb1                      8:17   0    2G  0 part
│ └─md0                     9:0    0    2G  0 raid1
└─sdb2                      8:18   0  511M  0 part
  └─md1                     9:1    0 1018M  0 raid0
sdc                         8:32   0  2.5G  0 disk
├─sdc1                      8:33   0    2G  0 part
│ └─md0                     9:0    0    2G  0 raid1
└─sdc2                      8:34   0  511M  0 part
  └─md1                     9:1    0 1018M  0 raid0

-- сохраняем:
root@vagrant:~# mdadm --detail --scan --verbose >> /etc/mdadm/mdadm.conf
root@vagrant:~# cat /etc/mdadm/mdadm.conf
### mdadm.conf
# This configuration was auto-generated on Tue, 24 Aug 2021 08:47:22 +0000 by mkconf
ARRAY /dev/md0 level=raid1 num-devices=2 metadata=1.2 name=vagrant:0 UUID=ae24daba:ddaf7bbb:4bfba54a:ea9d6a91
   devices=/dev/sdb1,/dev/sdc1
ARRAY /dev/md1 level=raid0 num-devices=2 metadata=1.2 name=vagrant:1 UUID=c6350044:7e53744f:2703c910:b6e86fd9
   devices=/dev/sdb2,/dev/sdc2

## 8. Создайте 2 независимых PV на получившихся md-устройствах.
root@vagrant:~# pvcreate /dev/md0 /dev/md1
  Physical volume "/dev/md0" successfully created.
  Physical volume "/dev/md1" successfully created.

## 9. Создайте общую volume-group на этих двух PV.
root@vagrant:~# vgcreate vol_group1 /dev/md0 /dev/md1
  Volume group "vol_group1" successfully created

root@vagrant:~# pvdisplay
  --- Physical volume ---
  PV Name               /dev/sda3
  VG Name               ubuntu-vg
  PV Size               <63.00 GiB / not usable 0
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              16127
  Free PE               8063
  Allocated PE          8064
  PV UUID               sDUvKe-EtCc-gKuY-ZXTD-1B1d-eh9Q-XldxLf

  --- Physical volume ---
  PV Name               /dev/md0
  VG Name               vol_group1
  PV Size               <2.00 GiB / not usable 0
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              511
  Free PE               511
  Allocated PE          0
  PV UUID               rGRpgA-gL8v-14Nh-tU01-od0Z-8kQA-tvbiWg

  --- Physical volume ---
  PV Name               /dev/md1
  VG Name               vol_group1
  PV Size               1018.00 MiB / not usable 2.00 MiB
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              254
  Free PE               254
  Allocated PE          0
  PV UUID               vrvCGl-LO3V-IELt-E2ur-npov-MqoL-dr4cb1

root@vagrant:~# pvdisplay
  --- Physical volume ---
  PV Name               /dev/sda3
  VG Name               ubuntu-vg
  PV Size               <63.00 GiB / not usable 0
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              16127
  Free PE               8063
  Allocated PE          8064
  PV UUID               sDUvKe-EtCc-gKuY-ZXTD-1B1d-eh9Q-XldxLf

  --- Physical volume ---
  PV Name               /dev/md0
  VG Name               vol_group1
  PV Size               <2.00 GiB / not usable 0
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              511
  Free PE               511
  Allocated PE          0
  PV UUID               rGRpgA-gL8v-14Nh-tU01-od0Z-8kQA-tvbiWg

  --- Physical volume ---
  PV Name               /dev/md1
  VG Name               vol_group1
  PV Size               1018.00 MiB / not usable 2.00 MiB
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              254
  Free PE               254
  Allocated PE          0
  PV UUID               vrvCGl-LO3V-IELt-E2ur-npov-MqoL-dr4cb1

root@vagrant:~# vgdisplay
  --- Volume group ---
  VG Name               ubuntu-vg
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  2
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               1
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <63.00 GiB
  PE Size               4.00 MiB
  Total PE              16127
  Alloc PE / Size       8064 / 31.50 GiB
  Free  PE / Size       8063 / <31.50 GiB
  VG UUID               aK7Bd1-JPle-i0h7-5jJa-M60v-WwMk-PFByJ7

  --- Volume group ---
  VG Name               vol_group1
  System ID
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               <2.99 GiB
  PE Size               4.00 MiB
  Total PE              765
  Alloc PE / Size       0 / 0
  Free  PE / Size       765 / <2.99 GiB
  VG UUID               pUgEBh-UAma-XgYF-uP2K-O3zT-XAhP-biapHk

## 10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.
root@vagrant:~# lvcreate -L 100M -n logical_vol1 vol_group1 /dev/md1
  Logical volume "logical_vol1" created.
  
root@vagrant:~# lvdisplay
  --- Logical volume ---
  LV Path                /dev/ubuntu-vg/ubuntu-lv
  LV Name                ubuntu-lv
  VG Name                ubuntu-vg
  LV UUID                ftN15m-3lML-YH5x-R5P2-kLCd-kzW3-32dlqO
  LV Write Access        read/write
  LV Creation host, time ubuntu-server, 2021-12-19 19:37:44 +0000
  LV Status              available
  # open                 1
  LV Size                31.50 GiB
  Current LE             8064
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0

  --- Logical volume ---
  LV Path                /dev/vol_group1/logical_vol1
  LV Name                logical_vol1
  VG Name                vol_group1
  LV UUID                YAv1eK-LVtF-mcGQ-uuwq-pALc-GAHd-Y4cG08
  LV Write Access        read/write
  LV Creation host, time vagrant, 2022-02-21 11:13:04 +0000
  LV Status              available
  # open                 0
  LV Size                100.00 MiB
  Current LE             25
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     4096
  Block device           253:1

## 11. Создайте mkfs.ext4 ФС на получившемся LV.
root@vagrant:~# mkfs.ext4 /dev/vol_group1/logical_vol1
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 25600 4k blocks and 25600 inodes

Allocating group tables: done
Writing inode tables: done
Creating journal (1024 blocks): done
Writing superblocks and filesystem accounting information: done

root@vagrant:~# lsblk
NAME                          MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
loop1                           7:1    0 70.3M  1 loop  /snap/lxd/21029
loop2                           7:2    0 55.4M  1 loop  /snap/core18/2128
loop3                           7:3    0 55.5M  1 loop  /snap/core18/2284
loop4                           7:4    0 43.6M  1 loop  /snap/snapd/14978
loop5                           7:5    0 61.9M  1 loop  /snap/core20/1328
loop6                           7:6    0 67.2M  1 loop  /snap/lxd/21835
sda                             8:0    0   64G  0 disk
├─sda1                          8:1    0    1M  0 part
├─sda2                          8:2    0    1G  0 part  /boot
└─sda3                          8:3    0   63G  0 part
  └─ubuntu--vg-ubuntu--lv     253:0    0 31.5G  0 lvm   /
sdb                             8:16   0  2.5G  0 disk
├─sdb1                          8:17   0    2G  0 part
│ └─md0                         9:0    0    2G  0 raid1
└─sdb2                          8:18   0  511M  0 part
  └─md1                         9:1    0 1018M  0 raid0
    └─vol_group1-logical_vol1 253:1    0  100M  0 lvm
sdc                             8:32   0  2.5G  0 disk
├─sdc1                          8:33   0    2G  0 part
│ └─md0                         9:0    0    2G  0 raid1
└─sdc2                          8:34   0  511M  0 part
  └─md1                         9:1    0 1018M  0 raid0
    └─vol_group1-logical_vol1 253:1    0  100M  0 lvm
	
## 12. Смонтируйте этот раздел в любую директорию, например, /tmp/new.
root@vagrant:~# mkdir /tmp/new
root@vagrant:~# mount /dev/vol_group1/logical_vol1 /tmp/new/
root@vagrant:~# df -h
Filesystem                           Size  Used Avail Use% Mounted on
/dev/mapper/ubuntu--vg-ubuntu--lv     31G  3.7G   26G  13% /
...
/dev/mapper/vol_group1-logical_vol1   93M   72K   86M   1% /tmp/new

## 13. Поместите туда тестовый файл, например wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz.
root@vagrant:~# wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz
--2022-02-21 11:16:37--  https://mirror.yandex.ru/ubuntu/ls-lR.gz
Resolving mirror.yandex.ru (mirror.yandex.ru)... 213.180.204.183, 2a02:6b8::183
Connecting to mirror.yandex.ru (mirror.yandex.ru)|213.180.204.183|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 22315112 (21M) [application/octet-stream]
Saving to: ‘/tmp/new/test.gz.’

/tmp/new/test.gz.                   100%[================================================================>]  21.28M  22.0MB/s    in 1.0s

2022-02-21 11:16:38 (22.0 MB/s) - ‘/tmp/new/test.gz.’ saved [22315112/22315112]

## 14. Прикрепите вывод lsblk.
root@vagrant:~# lsblk
NAME                          MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
loop1                           7:1    0 70.3M  1 loop  /snap/lxd/21029
loop2                           7:2    0 55.4M  1 loop  /snap/core18/2128
loop3                           7:3    0 55.5M  1 loop  /snap/core18/2284
loop4                           7:4    0 43.6M  1 loop  /snap/snapd/14978
loop5                           7:5    0 61.9M  1 loop  /snap/core20/1328
loop6                           7:6    0 67.2M  1 loop  /snap/lxd/21835
sda                             8:0    0   64G  0 disk
├─sda1                          8:1    0    1M  0 part
├─sda2                          8:2    0    1G  0 part  /boot
└─sda3                          8:3    0   63G  0 part
  └─ubuntu--vg-ubuntu--lv     253:0    0 31.5G  0 lvm   /
sdb                             8:16   0  2.5G  0 disk
├─sdb1                          8:17   0    2G  0 part
│ └─md0                         9:0    0    2G  0 raid1
└─sdb2                          8:18   0  511M  0 part
  └─md1                         9:1    0 1018M  0 raid0
    └─vol_group1-logical_vol1 253:1    0  100M  0 lvm   /tmp/new
sdc                             8:32   0  2.5G  0 disk
├─sdc1                          8:33   0    2G  0 part
│ └─md0                         9:0    0    2G  0 raid1
└─sdc2                          8:34   0  511M  0 part
  └─md1                         9:1    0 1018M  0 raid0
    └─vol_group1-logical_vol1 253:1    0  100M  0 lvm   /tmp/new
	
## 15. Протестируйте целостность файла:

root@vagrant:~# gzip -t /tmp/new/test.gz. | echo $?
0

## 16. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.
root@vagrant:~# pvmove -n /dev/vol_group1/logical_vol1 /dev/md1 /dev/md0
  /dev/md1: Moved: 28.00%
  /dev/md1: Moved: 100.00%
  
root@vagrant:~# lsblk
NAME                          MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
loop1                           7:1    0 70.3M  1 loop  /snap/lxd/21029
loop2                           7:2    0 55.4M  1 loop  /snap/core18/2128
loop3                           7:3    0 55.5M  1 loop  /snap/core18/2284
loop4                           7:4    0 43.6M  1 loop  /snap/snapd/14978
loop5                           7:5    0 61.9M  1 loop  /snap/core20/1328
loop6                           7:6    0 67.2M  1 loop  /snap/lxd/21835
sda                             8:0    0   64G  0 disk
├─sda1                          8:1    0    1M  0 part
├─sda2                          8:2    0    1G  0 part  /boot
└─sda3                          8:3    0   63G  0 part
  └─ubuntu--vg-ubuntu--lv     253:0    0 31.5G  0 lvm   /
sdb                             8:16   0  2.5G  0 disk
├─sdb1                          8:17   0    2G  0 part
│ └─md0                         9:0    0    2G  0 raid1
│   └─vol_group1-logical_vol1 253:1    0  100M  0 lvm   /tmp/new
└─sdb2                          8:18   0  511M  0 part
  └─md1                         9:1    0 1018M  0 raid0
sdc                             8:32   0  2.5G  0 disk
├─sdc1                          8:33   0    2G  0 part
│ └─md0                         9:0    0    2G  0 raid1
│   └─vol_group1-logical_vol1 253:1    0  100M  0 lvm   /tmp/new
└─sdc2                          8:34   0  511M  0 part
  └─md1                         9:1    0 1018M  0 raid0

## 17. Сделайте --fail на устройство в вашем RAID1 md.
root@vagrant:~# mdadm /dev/md0 -f /dev/sdc1
mdadm: set /dev/sdc1 faulty in /dev/md0
root@vagrant:~# cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]
md1 : active raid0 sdc2[1] sdb2[0]
      1042432 blocks super 1.2 512k chunks

md0 : active raid1 sdc1[1](F) sdb1[0]
      2094080 blocks super 1.2 [2/1] [U_]
	  
## 18. Подтвердите выводом dmesg, что RAID1 работает в деградированном состоянии.
root@vagrant:~# dmesg | grep raid
[ 2705.318807] md/raid1:md0: Disk failure on sdc1, disabling device.
               md/raid1:md0: Operation continuing on 1 devices.
			   
## 19. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:

root@vagrant:~# gzip -t /tmp/new/test.gz. | echo $?
0

## 20. Погасите тестовый хост, vagrant destroy.

c:\Users\skurudo\Dev2>vagrant destroy
   default: Are you sure you want to destroy the 'default' VM? [y/N] y
==> default:  Forciung shutdown VM...
==> default: Destroying VM and associated drives...