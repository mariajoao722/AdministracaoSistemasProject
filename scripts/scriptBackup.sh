#!/bin/bash
sudo apt-get update
sudo apt-get install -y ceph
sudo apt-get install rsync

ssh-keygen -C publicMethod5 -f /home/mjmarquespais/.ssh/publicMethod5 -N "" -q

