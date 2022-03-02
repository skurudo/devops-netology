# Домашнее задание к занятию "3.8. Компьютерные сети, лекция 3"

## 1. Подключитесь к публичному маршрутизатору в интернет. Найдите маршрут к вашему публичному IP

route-views>show ip route 195.94.242.18
Routing entry for 195.94.224.0/19, supernet
  Known via "bgp 6447", distance 20, metric 0
  Tag 6939, type external
  Last update from 64.71.137.241 1w4d ago
  Routing Descriptor Blocks:
  * 64.71.137.241, from 64.71.137.241, 1w4d ago
      Route metric is 0, traffic share count is 1
      AS Hops 2
      Route tag 6939
      MPLS label: none

route-views>show bgp 195.94.242.18
BGP routing table entry for 195.94.224.0/19, version 312528991
Paths: (23 available, best #16, table default)	  
 

## 2. Создайте dummy0 интерфейс в Ubuntu. Добавьте несколько статических маршрутов. Проверьте таблицу маршрутизации.

$ sudo modprobe -v dummy numdummies=1

vagrant@vagrant:~$ lsmod | grep dummy
dummy                  16384  0

vagrant@vagrant:~$ ip a | grep dummy
3: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN group default qlen 1000

vagrant@vagrant:~$ sudo ip addr add 192.168.168.168/24 dev dummy0
vagrant@vagrant:~$ ip a | grep dummy
3: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN group default qlen 1000
    inet 192.168.168.168/24 scope global dummy0

vagrant@vagrant:~$ ip route
default via 192.168.186.2 dev eth0 proto dhcp src 192.168.186.130 metric 100
192.168.186.0/24 dev eth0 proto kernel scope link src 192.168.186.130
192.168.186.2 dev eth0 proto dhcp scope link src 192.168.186.130 metric 100

$ sudo ip link set dummy0 up

$ sudo ip route add 1.1.1.1 via 192.168.168.168
$ sudo ip route add 2.2.2.2 via 192.168.186.130
$ sudo ip route add 3.3.3.3 via 192.168.186.123

vagrant@vagrant:~$ ip route
default via 192.168.186.2 dev eth0 proto dhcp src 192.168.186.130 metric 100
1.1.1.1 via 192.168.168.168 dev dummy0
2.2.2.2 via 192.168.186.130 dev eth0
3.3.3.3 via 192.168.186.123 dev eth0
192.168.168.0/24 dev dummy0 proto kernel scope link src 192.168.168.168
192.168.186.0/24 dev eth0 proto kernel scope link src 192.168.186.130
192.168.186.2 dev eth0 proto dhcp scope link src 192.168.186.130 metric 100

## 3. Проверьте открытые TCP порты в Ubuntu, какие протоколы и приложения используют эти порты? Приведите несколько примеров.

ipv4 / tcp - DNS - 53 - systemd-resolve 
ipv4 / tcp - SSH - 22 - sshd
ipv6 / tcp - 9100 - node_exporter
ipv4 / tcp - 19999, 8125 - netdata

...

vagrant@vagrant:~$ sudo lsof -i -P -n | grep LISTEN
systemd-r  709 systemd-resolve   13u  IPv4  22717      0t0  TCP 127.0.0.53:53 (LISTEN)
netdata    737         netdata    4u  IPv4  25909      0t0  TCP *:19999 (LISTEN)
netdata    737         netdata   55u  IPv4  27510      0t0  TCP 127.0.0.1:8125 (LISTEN)
prometheu  739   node_exporter    3u  IPv6  25537      0t0  TCP *:9100 (LISTEN)
sshd       815            root    3u  IPv4  25896      0t0  TCP *:22 (LISTEN)
sshd       815            root    4u  IPv6  25898      0t0  TCP *:22 (LISTEN)

grant@vagrant:~$ sudo ss -tulpn | grep LISTEN
tcp    LISTEN  0       4096                127.0.0.1:8125         0.0.0.0:*      users:(("netdata",pid=737,fd=55))
tcp    LISTEN  0       4096                  0.0.0.0:19999        0.0.0.0:*      users:(("netdata",pid=737,fd=4))
tcp    LISTEN  0       4096            127.0.0.53%lo:53           0.0.0.0:*      users:(("systemd-resolve",pid=709,fd=13))
tcp    LISTEN  0       128                   0.0.0.0:22           0.0.0.0:*      users:(("sshd",pid=815,fd=3))
tcp    LISTEN  0       4096                        *:9100               *:*      users:(("prometheus-node",pid=739,fd=3))
tcp    LISTEN  0       128                      [::]:22              [::]:*      users:(("sshd",pid=815,fd=4))

vagrant@vagrant:~$ ss -tulw
Netid       State        Recv-Q       Send-Q                    Local Address:Port                  Peer Address:Port       Process
icmp6       UNCONN       0            0                                *%eth0:ipv6-icmp                        *:*
udp         UNCONN       0            0                             127.0.0.1:8125                       0.0.0.0:*
udp         UNCONN       0            0                         127.0.0.53%lo:domain                     0.0.0.0:*
udp         UNCONN       0            0                  192.168.186.130%eth0:bootpc                     0.0.0.0:*
tcp         LISTEN       0            4096                          127.0.0.1:8125                       0.0.0.0:*
tcp         LISTEN       0            4096                            0.0.0.0:19999                      0.0.0.0:*
tcp         LISTEN       0            4096                      127.0.0.53%lo:domain                     0.0.0.0:*
tcp         LISTEN       0            128                             0.0.0.0:ssh                        0.0.0.0:*
tcp         LISTEN       0            4096                                  *:9100                             *:*
tcp         LISTEN       0            128                                [::]:ssh                           [::]:*

## 4. Проверьте используемые UDP сокеты в Ubuntu, какие протоколы и приложения используют эти порты?

vagrant@vagrant:~$ netstat -n --udp --listen
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State
udp        0      0 127.0.0.1:8125          0.0.0.0:*
udp        0      0 127.0.0.53:53           0.0.0.0:*
udp        0      0 192.168.186.130:68      0.0.0.0:*

ipv4 / udp - DNS - 53 - systemd-resolve 
ipv4 / udp - 8125 - netdata

## 5. Используя diagrams.net, создайте L3 диаграмму вашей домашней сети или любой другой сети, с которой вы работали
home network.drawio.pdf
home network.drawio.png
home network.drawio

