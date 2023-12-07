#!/bin/bash
sudo apt-get update
sudo apt-get install -y ceph
sudo apt-get install rsync

#https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories-pt

ssh-keygen -C publicMethod5 -f /home/mjmarquespais/.ssh/publicMethod5 -N "" -q

# sincronizar os ficheiros dentro da maquina backup
# rsync -a dir3/ dir2

# mandar do rdb para o backup (ainda nao funciona) (permission denied)
# rsync -avz --progress -v --rsh="ssh -i ~/.ssh/publicMethod3" dir1/ publicMethod3@10.204.0.14:mjmarquespais/dir2
