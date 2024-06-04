# utils

## Server sync

### Setup new server

```bash
git clone https://github.com/lacclab/utils.git && \
cd utils && \
bash server_sync/setup_new_server.sh --user-email <your_email> # --skip-conda if already have conda
```

### Setup new repo

```bash
cd && \
bash utils/server_sync/setup_repo_on_server.sh \
git@github.com:lacclab/Cognitive-State-Decoding.git \
--env-file environment.yml \
--additional-commands "python -m spacy download en_core_web_sm"
 # env-file and additional-command are optional
```

### Run command on all servers

```bash
# See how much space is used in the work folder
bash server_sync/run_command_all_servers.sh "du -h --max-depth=1 | grep ./<your work folder>"

# Cleanup models
bash server_sync/run_command_all_servers.sh "cd Cognitive-State-Decoding; git pull; python scripts/cleanup_models.py --keep_one_best --real_run"

# Check disk space
bash server_sync/run_command_all_servers.sh "df -h | grep /data"

# Update this repo on all servers
bash server_sync/run_command_all_servers.sh "cd utils; git pull"

bash server_sync/run_command_all_servers.sh "cd Cognitive-State-Decoding &&  git pull &&  git checkout main &&  git pull && source ~/miniforge3/etc/profile.d/mamba.sh && mamba activate decoding &&  mamba env update --file environment.yml"

```
