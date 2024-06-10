#!/bin/bash

s="$(head -1 private.auto.tfvars)"
s=${s#*'"'}; s=${s%'"'*}

echo "Token for login:"
echo "$s"


echo "Login to Yandex Docker Registry"
echo "$s" | docker login --username oauth --password-stdin cr.yandex
