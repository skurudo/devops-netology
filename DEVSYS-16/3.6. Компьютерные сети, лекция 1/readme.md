# Домашнее задание к занятию "3.6. Компьютерные сети, лекция 1"

## 1. Работа c HTTP через телнет.
* Подключитесь утилитой телнет к сайту stackoverflow.com telnet stackoverflow.com 80

sku@Angurva:~$ telnet stackoverflow.com 80
Trying 151.101.193.69...
Connected to stackoverflow.com.
Escape character is '^]'.

* отправьте HTTP запрос
GET /questions HTTP/1.0
HOST: stackoverflow.com
[press enter]
[press enter]

sku@Angurva:~$ telnet stackoverflow.com 80
Trying 151.101.193.69...
Connected to stackoverflow.com.
Escape character is '^]'.
GET /questions HTTP/1.0
HOST: stackoverflow.com

HTTP/1.1 301 Moved Permanently
cache-control: no-cache, no-store, must-revalidate
location: https://stackoverflow.com/questions
x-request-guid: 2aaa39a4-265b-4880-90b3-9032bb211ff1
feature-policy: microphone 'none'; speaker 'none'
content-security-policy: upgrade-insecure-requests; frame-ancestors 'self' https://stackexchange.com
Accept-Ranges: bytes
Date: Mon, 21 Feb 2022 11:47:10 GMT
Via: 1.1 varnish
Connection: close
X-Served-By: cache-ams21021-AMS
X-Cache: MISS
X-Cache-Hits: 0
X-Timer: S1645444030.027913,VS0,VE75
Vary: Fastly-SSL
X-DNS-Prefetch-Control: off
Set-Cookie: prov=12020bcb-52dc-35fb-45f7-8cc18014a814; domain=.stackoverflow.com; expires=Fri, 01-Jan-2055 00:00:00 GMT; path=/; HttpOnly

Connection closed by foreign host.

* В ответе укажите полученный HTTP код, что он означает?

301, *Код состояния HTTP 301 или Moved Permanently — стандартный код ответа HTTP, получаемый в ответ от сервера в ситуации, когда запрошенный ресурс был на постоянной основе перемещён в новое месторасположение, и указывающий на то, что текущие ссылки, использующие данный URL, должны быть обновлены.* Само перенаправление объявлено в location

## 2. Повторите задание 1 в браузере, используя консоль разработчика F12.
* откройте вкладку Network
* отправьте запрос http://stackoverflow.com
* найдите первый ответ HTTP сервера, откройте вкладку Headers
* укажите в ответе полученный HTTP код.
* проверьте время загрузки страницы, какой запрос обрабатывался дольше всего?
* приложите скриншот консоли браузера в ответ.

Status Code: 200 

Сама страница - жрущие жаба-скрипты заблокировались на подлете :)
см. скрины
2022-02-21_006.png
2022-02-21_007.png



## 3. Какой IP адрес у вас в интернете?
sku@Angurva:~$ wget -q -O - ifconfig.me/ip
195.94.242.18
sku@Angurva:~$ curl ifconfig.me/ip
195.94.242.18

## 4. Какому провайдеру принадлежит ваш IP адрес? Какой автономной системе AS? Воспользуйтесь утилитой whois

### Westcall - netname: RU-WEST-CALL-971204 / org-name:       OOO WestCall Ltd.
sku@Angurva:~$ whois 195.94.242.18 | grep 'netname\|org-name'

### AS 8595
sku@Angurva:~$ dig $(dig -x 195.94.242.18 | grep PTR | tail -n 1 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}').origin.asn.cymru.com TXT +short
"8595 | 195.94.224.0/19 | RU | ripencc | 1997-12-04"
или
sku@Angurva:~$ whois -h whois.cymru.com -- '-v 195.94.242.18'
AS      | IP               | BGP Prefix          | CC | Registry | Allocated  | AS Name
8595    | 195.94.242.18    | 195.94.224.0/19     | RU | ripencc  | 1997-12-04 | WESTCALL-AS, RU

### или одной командой получим все: 
sku@Angurva:~$ whois 195.94.242.18 | grep 'netname\|org-name\|origin'
netname:        RU-WEST-CALL-971204
org-name:       OOO WestCall Ltd.
origin:         AS8595

## 5. Через какие сети проходит пакет, отправленный с вашего компьютера на адрес 8.8.8.8? Через какие AS? Воспользуйтесь утилитой traceroute

sku@Angurva:~$ traceroute -An 8.8.8.8
traceroute: invalid option -- 'A'
Try 'traceroute --help' or 'traceroute --usage' for more information

sku@Angurva:~$ sudo apt install traceroute && sudo apt remove inetutils-traceroute

sku@Angurva:~$ traceroute -An 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  * * *
 2  * * *
 3  * * *
 4  * * *
 5  * * *
 6  * * *
 7  * * *
 8  * * *
 9  * * *
10  * * *
11  * * *
12  * * *
13  * * *
14  * * *
15  * * *
16  * * *
17  * * *
18  * * *
19  * * *
20  * * *
21  * * *
22  * * *
23  * * *
24  * * *
25  * * *
26  * * *
27  * * *
28  * * *
29  * * *
30  * * *

попробуем на другой виртуалке, чтобы хоть что-то посмотреть, а то как-то грустно у WestCall

[sku@arms:~ ] $ traceroute -An 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  89.208.137.247 [AS48282]  0.453 ms  0.415 ms  0.401 ms
 2  172.31.0.7 [*]  0.456 ms 172.31.0.3 [*]  0.414 ms 172.31.0.7 [*]  0.472 ms
 3  109.239.136.80 [AS31500]  1.369 ms 178.18.227.7 [AS50952]  2.029 ms 195.208.208.232 [AS5480]  1.630 ms
 4  108.170.250.130 [AS15169]  2.092 ms 108.170.250.83 [AS15169]  1.844 ms 108.170.250.130 [AS15169]  1.980 ms
 5  72.14.232.85 [AS15169]  11.149 ms * 142.251.49.158 [AS15169]  15.501 ms
 6  142.251.61.221 [AS15169]  18.796 ms 74.125.253.109 [AS15169]  17.785 ms 172.253.65.82 [AS15169]  26.946 ms
 7  172.253.51.239 [AS15169]  17.866 ms 142.250.56.217 [AS15169]  17.274 ms 172.253.51.243 [AS15169]  16.117 ms
 8  * * *
 9  * * *
10  * * *
11  * * *
12  * * *
13  * * *
14  * * *
15  * * *
16  * 8.8.8.8 [AS15169]  13.908 ms *

## 6. Повторите задание 5 в утилите mtr. На каком участке наибольшая задержка - delay?
 $ mtr 8.8.8.8
 3 хоп - 167 - Wrst значение
 
 см. 2022-02-21_004.png
 
 ## 7. Какие DNS сервера отвечают за доменное имя dns.google? Какие A записи? воспользуйтесь утилитой dig
 
sku@Angurva:~$ whois dns.google | grep "Name Server"
Name Server: ns1.zdns.google
Name Server: ns2.zdns.google
Name Server: ns3.zdns.google
Name Server: ns4.zdns.google

sku@Angurva:~$ dig NS dns.google | grep A
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 17072
;; flags: qr rd ra; QUERY: 1, ANSWER: 4, AUTHORITY: 0, ADDITIONAL: 9
;; ANSWER SECTION:
;; ADDITIONAL SECTION:
ns2.zdns.google.        21489   IN      A       216.239.34.114
ns2.zdns.google.        21566   IN      AAAA    2001:4860:4802:34::72
ns3.zdns.google.        21034   IN      A       216.239.36.114
ns3.zdns.google.        21566   IN      AAAA    2001:4860:4802:36::72
ns4.zdns.google.        21566   IN      A       216.239.38.114
ns4.zdns.google.        21566   IN      AAAA    2001:4860:4802:38::72
ns1.zdns.google.        20792   IN      A       216.239.32.114
ns1.zdns.google.        21566   IN      AAAA    2001:4860:4802:32::72

## 8. Проверьте PTR записи для IP адресов из задания 7. Какое доменное имя привязано к IP? воспользуйтесь утилитой dig

sku@Angurva:~$ dig -x 216.239.34.114 | grep PTR
;114.34.239.216.in-addr.arpa.   IN      PTR
114.34.239.216.in-addr.arpa. 21575 IN   PTR     ns2.zdns.google.

sku@Angurva:~$ dig -x 216.239.36.114 | grep PTR
;114.36.239.216.in-addr.arpa.   IN      PTR
114.36.239.216.in-addr.arpa. 21600 IN   PTR     ns3.zdns.google.

sku@Angurva:~$ dig -x 216.239.38.114 | grep PTR
;114.38.239.216.in-addr.arpa.   IN      PTR
114.38.239.216.in-addr.arpa. 19634 IN   PTR     ns4.zdns.google.

sku@Angurva:~$ dig -x 216.239.32.114 | grep PTR
;114.32.239.216.in-addr.arpa.   IN      PTR
114.32.239.216.in-addr.arpa. 21600 IN   PTR     ns1.zdns.google.
