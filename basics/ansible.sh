#!/bin/bash
ansible-playbook setup_ansible_apps.yml --ask-become-pass -i inventory.ini
