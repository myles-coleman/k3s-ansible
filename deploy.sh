#!/bin/bash

ansible-playbook site.yml -i inventory/homelab-cluster/hosts.ini --ask-vault-pass