#!/bin/bash

# Example usage:
# bash server_sync/run_command_all_servers.sh "cd Cognitive-State-Decoding; git checkout may-runs-shubi; git pull; mamba activate decoding; mamba env update --file environment.yml"

# Check if command is provided
if [ -z "$1" ]; then
    echo "No command provided. Usage: ./run_command_on_all_servers.sh <command>"
    exit 1
fi

command_to_run=$1
user=$(whoami)

# Run the command on each server listed in server_list.txt
while IFS= read -r server; do
    echo "Running command on $user@$server.iem.technion.ac.il"
    ssh $user@$server.iem.technion.ac.il "$command_to_run"
done <server_sync/server_list.txt
