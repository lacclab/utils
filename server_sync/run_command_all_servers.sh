#!/bin/bash

# Example usage:
# bash server_sync/run_command_all_servers.sh "cd Cognitive-State-Decoding; git checkout may-runs-shubi; git pull; source $HOME/miniforge3/etc/profile.d/conda.sh; source $HOME/miniforge3/etc/profile.d/mamba.sh; mamba activate decoding; mamba env update --file environment.yml"

# Check if command is provided
if [ -z "$1" ]; then
    echo "No command provided. Usage: ./run_command_on_all_servers.sh <command>"
    exit 1
fi

command_to_run=$1
user=$(whoami)

# Run the command on each server listed in server_list.txt
while IFS= read -r server; do
    # Skip if server starts with #
    if [[ $server == \#* ]]; then
        echo "Skipping server: $server"
        continue
    fi
    echo "$server:"
    (ssh $user@$server.iem.technion.ac.il "$command_to_run" &)
    sleep 3
done <server_sync/server_list.txt
wait
