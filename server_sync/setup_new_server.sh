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
skip_conda=false
skip_clone=false

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
  --skip-conda)
    skip_conda=true
    shift
    ;;
  --skip-clone)
    skip_clone=true
    shift
    ;;
  --environment-file)
    environment_file="$2"
    shift 2
    ;;
  *)
    repo_path="$1"
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

###### Install zsh plugins

# oh my zsh
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

# install powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# install zsh autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# the fuck
pip3 install thefuck --user

#### Git Config
# TODO generalize email and user!!
git config --global user.email "omer.shubi@gmail.com"
git config --global user.name "Shubi (nlp16)"
