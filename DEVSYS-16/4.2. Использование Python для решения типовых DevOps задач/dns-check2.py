#!/usr/bin/env python3
import socket

check_names=["drive.google.com", "mail.google.com", "google.com"]
check_ip=["0.0.0.0", "0.0.0.0", "0.0.0.0"]

for i in range(0, 3):
    check_ip[i] = socket.gethostbyname(check_names[i])
    #print(check_names[i] + ' - ' + check_ip[i])
 
z=0
while z<100:
    for i in range(0, 3):
        if check_ip[i] != socket.gethostbyname(check_names[i]):                
            print("EROR", check_names[i], " IP mismatch: ", check_ip[i], socket.gethostbyname(check_names[i]))
        else:
            print(check_names[i] + ' - ' + check_ip[i])
z=z+1
    
        