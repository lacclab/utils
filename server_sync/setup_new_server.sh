#!/bin/bash
# Script Name: setup_new_server.sh
# Description: This script sets up a new server by installing conda, configuring git, and installing various zsh plugins.
#              It takes optional command-line arguments:
#              1. --skip-conda: A flag to skip downloading and installing conda (default is false).
#              2. --user-email: The user's email for git configuration.
# Usage:
# ./setup_new_server.sh [--skip-conda] [--user-email user_email]
# Examples:
# ./setup_new_server.sh
# ./setup_new_server.sh --skip-conda
# ./setup_new_server.sh --user-email <your_email>

# Exit if any command fails
set -e

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



###### Install zsh plugins

# oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# install powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# install zsh autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --key-bindings --completion --no-update-rc

# Copy template_zshrc to .zshrc
cp ~/utils/server_sync/template_zshrc ~/.zshrc
# Replace "user" with the current user
sed -i "s/<user>/$(whoami)/g" ~/.zshrc

# copy template_p10k_config to .p10k.zsh
cp ~/utils/server_sync/template_p10k_config ~/.p10k.zsh

source ~/.zshrc

# the fuck
pip3 install thefuck --user

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

# You should use zsh, but just in case sticking to bash use shared huggingface cache dir
echo 'export HF_HOME=/data/home/shared/.cache/huggingface' >>~/.bashrc
echo 'export HF_DATASETS_CACHE=/data/home/shared/.cache/huggingface' >>~/.bashrc
echo 'export HUGGINGFACE_HUB_CACHE=/data/home/shared/.cache/huggingface' >>~/.bashrc
# echo 'export TRANSFORMERS_CACHE=/data/home/shared/.cache/huggingface' >> ~/.bashrc # if using old hugginface transformers library
# source ~/.bashrc

curl -fsSL https://install.julialang.org | sh
