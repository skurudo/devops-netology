#!/usr/bin/env python3
import socket
import json
import yaml

with open('name.json', 'r') as j:
name_listold = json.load(j)
name_list = name_listold.copy()

for names in name_list:
    ips =  socket.gethostbyname(names)
    name_list[names] = ips
        if name_list.get(names) != name_listold.get(names):
            print("[error]: ", names, " IP mismatch: ", name_listold.get(names), " New ip: ", name_list.get(names),)
        else:
            print(names, "new ip: ", name_list.get(names))

    with open('name.json', 'w') as j:
        j.write(json.dumps(name_list))
    with open('name.yaml', 'w') as yam:
        yam.write(yaml.dump(name_list))

