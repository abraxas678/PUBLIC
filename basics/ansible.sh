#!/bin/bash
ansible-playbook ~/bin/setup_ansible_apps.yml --ask-become-pass -i ~/.config/ansible/inventory.ini
