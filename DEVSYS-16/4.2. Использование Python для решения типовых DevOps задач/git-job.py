#!/usr/bin/env python3
import os
git_path="/home/vagrant/devops-netology"
bash_command = ["cd " + git_path, "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(git_path+prepare_result)
