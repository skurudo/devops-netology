# 3.9. Элементы безопасности информационных систем"

## 1. Установите Bitwarden плагин для браузера. Зарегестрируйтесь и сохраните несколько паролей.
done 
2022-02-28_005.png

## 2. Установите Google authenticator на мобильный телефон. Настройте вход в Bitwarden акаунт через Google authenticator OTP.
done
2022-02-28_006.png

## 3. Установите apache2, сгенерируйте самоподписанный сертификат, настройте тестовый сайт для работы по HTTPS.
vagrant@vagrant:~$ sudo apt install apache2

vagrant@vagrant:~$ systemctl status apache2
● apache2.service - The Apache HTTP Server
     Loaded: loaded (/lib/systemd/system/apache2.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2022-02-28 19:53:14 UTC; 22s ago
	 
vagrant@vagrant:~$ sudo a2enmod ssl
vagrant@vagrant:~$ sudo systemctl restart apache2

vagrant@vagrant:~$ sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt

Country Name (2 letter code) [AU]:RU
State or Province Name (full name) [Some-State]:MSK
Locality Name (eg, city) []:Moscow
Organization Name (eg, company) [Internet Widgits Pty Ltd]:WWWA
Organizational Unit Name (eg, section) []:HomeBase
Common Name (e.g. server FQDN or YOUR name) []:test.ru
Email Address []:test@test.ru

vagrant@vagrant:~$ sudo nano /etc/apache2/sites-available/test.conf
vagrant@vagrant:~$ sudo mkdir /var/www/test-ru
vagrant@vagrant:~$ sudo nano  /var/www/test-ru/index.html

vagrant@vagrant:~$ sudo a2ensite test.conf
Enabling site test.
To activate the new configuration, you need to run:
  systemctl reload apache2

vagrant@vagrant:~$ sudo apache2ctl configtest
AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 127.0.1.1. Set the 'ServerName' directive globally to suppress this message
Syntax OK

vagrant@vagrant:~$ sudo systemctl reload apache2

vagrant@vagrant:~$ sudo nano /etc/hosts
127.0.0.1 test.ru

$ lynx https://test.ru
SSL error:The certificate is NOT trusted. The certificate issuer is unknown. -Continue? (n) y

собственно все, видим содержимое index.html - test
2022-02-28_007.png

ну и зафиналим, проверим сертификат:
vagrant@vagrant:~$ echo | openssl s_client -servername test.ru -connect test.ru:443
CONNECTED(00000003)
depth=0 C = RU, ST = MSK, L = Moscow, O = WWWA, OU = HomeBase, CN = test.ru, emailAddress = test@test.ru

## 4. Проверьте на TLS уязвимости произвольный сайт в интернете (кроме сайтов МВД, ФСБ, МинОбр, НацБанк, РосКосмос, РосАтом, РосНАНО и любых госкомпаний, объектов КИИ, ВПК ... и тому подобное).

vagrant@vagrant:~$ sudo snap install testssl
testssl 3.0.4snap1 from Kyle Fazzari (kyrofa) installed

vagrant@vagrant:~$ testssl skurudo.ru
 Testing protocols via sockets except NPN+ALPN
 SSLv2      not offered (OK)
 SSLv3      not offered (OK)
 TLS 1      not offered
 TLS 1.1    not offered
 TLS 1.2    offered (OK)
 TLS 1.3    offered (OK): final
 NPN/SPDY   h2, http/1.1 (advertised)
 ALPN/HTTP2 h2, http/1.1 (offered)
 
 или так...
 
 vagrant@vagrant:~$ sudo apt install nmap
 
 vagrant@vagrant:~$  nmap --script ssl-cert,ssl-enum-ciphers -p 443 skurudo.ru
Starting Nmap 7.80 ( https://nmap.org ) at 2022-02-28 20:15 UTC
Nmap scan report for skurudo.ru (195.2.70.110)
Host is up (0.0025s latency).
Other addresses for skurudo.ru (not scanned): 2a0d:8480:2::3e4
rDNS record for 195.2.70.110: arms.su

PORT    STATE SERVICE
443/tcp open  https
| ssl-cert: Subject: commonName=skurudo.ru
| Subject Alternative Name: DNS:skurudo.ru, DNS:www.skurudo.ru
| Issuer: commonName=R3/organizationName=Let's Encrypt/countryName=US
| Public Key type: rsa
| Public Key bits: 4096
| Signature Algorithm: sha256WithRSAEncryption
| Not valid before: 2022-01-03T22:21:26
| Not valid after:  2022-04-03T22:21:25
| MD5:   051d 8e28 a922 c82c 7210 d7aa 3b1b 9d6a
|_SHA-1: 9420 93cb 1fe7 88cf 147d 225e 07de 8297 82b6 744f
| ssl-enum-ciphers:
|   TLSv1.2:
|     ciphers:
|       TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256 (secp384r1) - A
|       TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 (secp384r1) - A
|       TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 (secp384r1) - A
|       TLS_DHE_RSA_WITH_AES_128_GCM_SHA256 (dh 4096) - A
|       TLS_DHE_RSA_WITH_AES_256_GCM_SHA384 (dh 4096) - A
|       TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256 (secp384r1) - A
|       TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384 (secp384r1) - A
|       TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA (secp384r1) - A
|       TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA (secp384r1) - A
|       TLS_DHE_RSA_WITH_AES_128_CBC_SHA256 (dh 4096) - A
|       TLS_DHE_RSA_WITH_AES_128_CBC_SHA (dh 4096) - A
|       TLS_DHE_RSA_WITH_AES_256_CBC_SHA256 (dh 4096) - A
|       TLS_DHE_RSA_WITH_AES_256_CBC_SHA (dh 4096) - A
|       TLS_RSA_WITH_AES_128_GCM_SHA256 (rsa 4096) - A
|       TLS_RSA_WITH_AES_256_GCM_SHA384 (rsa 4096) - A
|       TLS_RSA_WITH_AES_128_CBC_SHA256 (rsa 4096) - A
|       TLS_RSA_WITH_AES_256_CBC_SHA256 (rsa 4096) - A
|       TLS_RSA_WITH_AES_128_CBC_SHA (rsa 4096) - A
|       TLS_RSA_WITH_AES_256_CBC_SHA (rsa 4096) - A
|     compressors:
|       NULL
|     cipher preference: server
|_  least strength: A

Nmap done: 1 IP address (1 host up) scanned in 1.15 seconds
 
## 5. Установите на Ubuntu ssh сервер, сгенерируйте новый приватный ключ. Скопируйте свой публичный ключ на другой сервер. Подключитесь к серверу по SSH-ключу.

$ mkdir -p ~/.ssh && chmod 700 ~/.ssh
$ ssh-keygen 
$ ssh-copy-id vagrant@test.test.ru

## 6. Переименуйте файлы ключей из задания 5. Настройте файл конфигурации SSH клиента, так чтобы вход на удаленный сервер осуществлялся по имени сервера.

$ touch ~/.ssh/config
$ chmod 600 ~/.ssh/config
$ mv ~/.ssh/id_rsa.pub ~/.ssh/test.key
$ nano ~/.ssh/config

Host test
    HostName test.test.ru
    User vagrant
    Port 22
	IdentityFile ~/.ssh/test.key
	
$ ssh test
	
## 7. Соберите дамп трафика утилитой tcpdump в формате pcap, 100 пакетов. Откройте файл pcap в Wireshark.

сделаем на onworks.net
$ ip a 
$ sudo tcpdump -c 100 -i ens3 -w 100.pcap

2022-02-28_008.png
2022-02-28_009.png

и посмотрим результаты:
2022-02-28_010.png
2022-02-28_011.png
2022-02-28_012.png

## 8*. Просканируйте хост scanme.nmap.org. Какие сервисы запущены?
ssh, http, nping-echo

vagrant@vagrant:~$ nmap –sV scanme.nmap.org
vagrant@vagrant:~$ nmap scanme.nmap.org
Starting Nmap 7.80 ( https://nmap.org ) at 2022-02-28 20:17 UTC
Nmap scan report for scanme.nmap.org (45.33.32.156)
Host is up (0.17s latency).
Other addresses for scanme.nmap.org (not scanned): 2600:3c01::f03c:91ff:fe18:bb2f
Not shown: 997 filtered ports
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
9929/tcp open  nping-echo

Nmap done: 1 IP address (1 host up) scanned in 17.23 seconds

## 9*. Установите и настройте фаервол ufw на web-сервер из задания 3. Откройте доступ снаружи только к портам 22,80,443
vagrant@vagrant:~$ sudo apt install ufw
Reading package lists... Done
Building dependency tree
Reading state information... Done
ufw is already the newest version (0.36-6ubuntu1).
0 upgraded, 0 newly installed, 0 to remove and 39 not upgraded.

vagrant@vagrant:~$ ufw status
ERROR: You need to be root to run this script
vagrant@vagrant:~$ sudo ufw status
Status: inactive

vagrant@vagrant:~$ sudo ufw default deny incoming
Default incoming policy changed to 'deny'
(be sure to update your rules accordingly)
vagrant@vagrant:~$ sudo ufw default allow outgoing
Default outgoing policy changed to 'allow'
(be sure to update your rules accordingly)

vagrant@vagrant:~$ sudo ufw allow 22
Rules updated
Rules updated (v6)
vagrant@vagrant:~$ sudo ufw allow 80
Rules updated
Rules updated (v6)
vagrant@vagrant:~$ sudo ufw allow 443
Rules updated
Rules updated (v6)
vagrant@vagrant:~$ sudo ufw enable
Command may disrupt existing ssh connections. Proceed with operation (y|n)? y
Firewall is active and enabled on system startup

vagrant@vagrant:~$ sudo ufw status
Status: active

To                         Action      From
--                         ------      ----
22                         ALLOW       Anywhere
80                         ALLOW       Anywhere
443                        ALLOW       Anywhere
22 (v6)                    ALLOW       Anywhere (v6)
80 (v6)                    ALLOW       Anywhere (v6)
443 (v6)                   ALLOW       Anywhere (v6)
