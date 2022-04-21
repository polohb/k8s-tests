#!/bin/bash


cat << EOF >>  ~/.ssh/config

# k8s cluster

 Host 192.168.144.201
    User debian
    IdentityFile ~/.ssh/id_rsa

 Host 192.168.144.202
    User debian
    IdentityFile ~/.ssh/id_rsa

 Host 192.168.144.203
    User debian
    IdentityFile ~/.ssh/id_rsa


EOF