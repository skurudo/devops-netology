#!/bin/bash

s="$(head -1 private.auto.tfvars)"
s=${s#*'"'}; s=${s%'"'*}

echo "Token for login:"
echo "$s"


echo "Login to Yandex Docker Registry"
echo "$s" | docker login --username oauth --password-stdin cr.yandex


echo "Registry ID"
rid="$(head -1 registry-id)"
echo "$rid"


echo "-------"
echo "Build and push app"
cd ~/pro-one-app
docker build . -t cr.yandex/$rid/pro-one-app:latest -f ~/pro-one-app/Dockerfile
docker push cr.yandex/${rid}/pro-one-app:latest
