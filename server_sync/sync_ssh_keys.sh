#!/bin/bash

# Script Name: sync_ssh_keys.sh
# Description: This script is used to synchronize SSH keys between the local machine and a set of remote servers.
#              It uses the rsync command to perform the synchronization.
#              The script now reads the list of servers from a file named server_list.txt.
#              The rsync command is used with the -avzP flags to save attributes, archive, compress, and show progress during the synchronization.
# Usage: ./sync_ssh_keys.sh
# Author: Shubi
# Date: 16-04-2024

# Get the current logged in user
user=$(whoami)


# Sync with ZEUS
rsync -avzP ~/.ssh/ $user@zeus.technion.ac.il:/home/$user/.ssh

# Sync with DGX
rsync -avzP ~/.ssh/ $user@dgx-master.technion.ac.il:/home/$user/.ssh

# Read each line in the server_list.txt file
while IFS= read -r server; do
    echo "Synchronizing SSH keys with $user@$server.iem.technion.ac.il:/data/home/$user/.ssh"
    rsync -avzP ~/.ssh/ $user@$server.iem.technion.ac.il:/data/home/$user/.ssh
done < server_sync/server_list.txt

