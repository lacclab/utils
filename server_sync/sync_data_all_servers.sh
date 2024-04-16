#!/bin/bash

#TODO update include exlcude pattern
data_path="/data/home/shared/onestop/processed"

user=$(whoami)
while IFS= read -r server; do
    echo "Synchronizing data with $user@$server.iem.technion.ac.il:$data_path"
    rsync --mkpath -avzP $data_path/ $user@$server.iem.technion.ac.il:$data_path --exclude='*.pkl'  # --include='*.tsv' --exclude='*'
done < server_sync/server_list.txt

