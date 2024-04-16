#!/bin/bash

#TODO update include exlcude pattern
data_path="/data/home/shared/onestop/processed"

user=$(whoami)
for i in {08..20}; do
    ssh $user@nlp$i.iem.technion.ac.il "mkdir -p $data_path"
    rsync -avzP $data_path/ $user@nlp$i.iem.technion.ac.il:$data_path # --include='*.tsv' --exclude='*'
done

for i in {1..2}; do
    ssh $user@nlp-srv$i.iem.technion.ac.il "mkdir -p $data_path"
    rsync -avzP $data_path/ $user@nlp-srv$i.iem.technion.ac.il:$data_path # --include='*.tsv' --exclude='*'
done
