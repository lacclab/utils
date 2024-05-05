#!/bin/bash

#TODO update include exlcude pattern
data_path="/data/home/shared/onestop/processed"
dgx_data_path="/home/kfir-hadar/work/data/onestop/processed"
user=$(whoami)

if [ "$user" == "kfir-hadar" ]; then
    echo "Synchronizing data with dgx-master.technion.ac.il:$dgx_data_path"
    rsync --mkpath -avzP $data_path/ $user@dgx-master.technion.ac.il:$dgx_data_path --exclude='*.pkl' # --include='*.tsv' --exclude='*'
    ssh $user@dgx-master.technion.ac.il "chmod -R g+rX $dgx_data_path"
fi

while IFS= read -r server; do
    echo "Synchronizing data with $user@$server.iem.technion.ac.il:$data_path"
    rsync --mkpath -avzP $data_path/ $user@$server.iem.technion.ac.il:$data_path --exclude='*.pkl' # --include='*.tsv' --exclude='*'
done <server_sync/server_list.txt
