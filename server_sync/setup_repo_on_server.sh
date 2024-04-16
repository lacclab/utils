#!/bin/bash
# This script sets up a new server by installing conda, cloning a git repository, and setting up a conda environment.
# It takes optional command-line arguments:
# 1. The URL of the repository to clone (default is "https://github.com/user/repo.git").
# 2. Flag to skip downloading and installing conda (default is false).
# 3. Flag to skip cloning the repository (default is false).
# 4. The name of the environment file (default is "environment.yml").
# Creates a conda environment if the specified environment file exists in the repository.
#
# Usage:
# ./setup_new_server.sh [repo_url] [--skip-conda] [--skip-clone] [--environment-file env_file]
#
# Examples:
# ./setup_new_server.sh
# ./setup_new_server.sh https://github.com/lacclab/Cognitive-State-Decoding.git
# ./setup_new_server.sh https://github.com/lacclab/Cognitive-State-Decoding.git --skip-conda
# ./setup_new_server.sh https://github.com/lacclab/Cognitive-State-Decoding.git --skip-clone
# ./setup_new_server.sh https://github.com/lacclab/Cognitive-State-Decoding.git --environment-file my_env.yml
#
# To run the script directly from GitHub:
# git clone https://gist.github.com/814eb6a9a8b59febbcfcc79288630b60.git code_setup && bash code_setup/setup_new_server.sh https://github.com/lacclab/Cognitive-State-Decoding.git

# Exit if any command fails
set -e



# Default values
default_repo="https://github.com/user/repo.git"
environment_file="environment.yml"

# Hardcode conda_path to miniforge3 directory in home directory
conda_path="${HOME}/miniforge3"

# Activate conda and mamba without opening a new terminal
source "${conda_path}/etc/profile.d/conda.sh"
source "${conda_path}/etc/profile.d/mamba.sh"
conda activate

# Extract the repo name from the URL
repo_name=$(basename $repo_path | sed -e 's/.git$//')

# Print the path and name of the repository
echo "Repo path: $repo_path"
echo "Repo name: $repo_name"

git clone $repo_path

# Change directory to the cloned repository
cd $repo_name

# Create a conda environment if the specified environment file exists
if [ -f "$environment_file" ]; then
  mamba env create -f "$environment_file"
else
  # Print a message if the environment file is not found
  echo "$environment_file not found. Environment not set up."
fi



python -m spacy download en_core_web_sm
