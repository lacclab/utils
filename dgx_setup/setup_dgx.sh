#!/bin/bash

# Exit if any command fails
# set -e

# Default values
skip_conda=false
user_email=""

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
    --skip-conda)
        skip_conda=true
        shift
        ;;
    --user-email)
        user_email="$2"
        shift 2
        ;;
    *)
        shift
        ;;
    esac
done

# Install conda if not skipped and not already installed
if [ "$skip_conda" = false ] && ! command -v conda &>/dev/null; then
    # Download mamba (+conda) if not already installed
    curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
    # -b for skipping manual intervention
    bash Miniforge3-$(uname)-$(uname -m).sh -b
    # Remove the installation file
    rm Miniforge3-$(uname)-$(uname -m).sh
fi

# Hardcode conda_path to miniforge3 directory in home directory
conda_path="${HOME}/miniforge3"

# Activate conda and mamba without opening a new terminal
source "${conda_path}/etc/profile.d/conda.sh"
source "${conda_path}/etc/profile.d/mamba.sh"
conda activate

echo "Conda is installed at: ${conda_path}"
# Print the path where conda is installed
echo "Conda path: $conda_path"

#### Git Config
user=$(whoami)
full_server_name=$(hostname)
server_name=$(echo $full_server_name | cut -d'.' -f1)

git config --global user.name "$user ($server_name)"
git config --global core.sshCommand "ssh -i ~/.ssh/server2github"

# Check if user email is provided
if [ -z "$user_email" ]; then
    echo "No user email provided. Skipping git configuration."
else
    # Configure git with the provided user email
    git config --global user.email "$user_email"
fi


