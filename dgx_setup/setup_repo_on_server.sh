#!/bin/bash

# Default values
repo_path="https://github.com/user/repo.git"
environment_file="environment.yml"

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
    --env-file)
        environment_file="$2"
        shift 2
        ;;
    *)
        repo_path="$1"
        shift
        ;;
    esac
done

# Hardcode conda_path to miniforge3 directory in home directory
conda_path="${HOME}/miniforge3"

# Check if conda and mamba are installed
if [ ! -d "$conda_path" ]; then
    echo "Conda and mamba are not installed in the expected location: $conda_path"
    exit 1
fi

# Activate conda and mamba without opening a new terminal
source "${conda_path}/etc/profile.d/conda.sh"
source "${conda_path}/etc/profile.d/mamba.sh"
conda activate

# Extract the repo name from the URL
repo_name=$(basename $repo_path | sed -e 's/.git$//')

# Print the path and name of the repository
echo "Repo path: $repo_path"
echo "Repo name: $repo_name"

# Clone the repository
if git clone $repo_path; then
    cd $repo_name
else
    echo "Failed to clone repository: $repo_path"
    exit 1
fi
# Create a conda environment if the specified environment file exists
if [ -f "$environment_file" ]; then
    mamba env create -f "$environment_file"
    # Extract the environment name from the environment file
    env_name=$(head -n 1 "$environment_file" | cut -d ' ' -f 2)
    # Activate the newly created environment
    conda activate "$env_name"
else
    # Print a message if the environment file is not found
    echo "$environment_file not found. Environment not set up."
fi

ln -s /rg/berzak_prj/kfir-hadar/data ln_shared_data

# Weights and Biases
wandb login
# Click on url (https://wandb.ai/authorize) to authorize and paste the code in the terminal