#!/bin/bash

#TODO update include exlcude pattern
data_path="/data/home/shared/onestop/processed"

user=$(whoami)
while IFS= read -r server; do
    echo "Synchronizing data with $user@$server.iem.technion.ac.il:$data_path"
    ssh $user@$server.iem.technion.ac.il "mkdir -p $data_path"
    rsync -avzP $data_path/ $user@$server.iem.technion.ac.il:$data_path # --include='*.tsv' --exclude='*'
done < server_sync/server_list.txt

