#!/bin/bash

user=$(whoami)
for i in {08..20}; do
    rsync -avz --progress ~/.ssh/ $user@nlp$server.iem.technion.ac.il:/data/home/$user/.ssh
done

for i in {1..2}; do
    rsync -avz --progress ~/.ssh/ $user@nlp-srv$server.iem.technion.ac.il:/data/home/$user/.ssh
done