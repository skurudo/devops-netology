#!/usr/bin/env python3
import socket

dns_list_name=["drive.google.com", "mail.google.com", "google.com"]
dns_list_ipaddress=["0", "0", "0"]

for i in range(0, 3):
    dns_list_ipaddress[i]=socket.gethostbyname(dns_list_name[i])
    print(dns_list_name[i],dns_list_ipaddress[i])
    k=0
    while k<200:
        for i in range(0, 3):
            if dns_list_ipaddress[i] != socket.gethostbyname(dns_list_name[i]):
                print("EROR", dns_list_name[i],dns_list_ipaddress[i],socket.gethostbyname(dns_list_name[i]))
            else:
                        print(dns_list_name[i], dns_list_ipaddress[i])
    k=k+1