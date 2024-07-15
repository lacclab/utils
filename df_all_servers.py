"""Based on https://www.datacamp.com/tutorial/how-to-send-slack-messages-with-python,
and https://claude.site/artifacts/fda06428-5022-474c-b331-4f15749ebd0a
run crontab -e
then
SLACK_API_TOKEN="XXX"

0 0 * * * ~/miniforge3/envs/slack/bin/python /data/home/shubi/utils/df_all_servers.py

to run the script (assuming conda environment is 'slack' with slack_sdk, paramiko and pandas installed)
"""

import os
from slack_sdk import WebClient
from slack_sdk.errors import SlackApiError
from datetime import datetime
import paramiko
import pandas as pd
from io import StringIO

# Slack API token
SLACK_TOKEN = os.environ.get("SLACK_API_TOKEN")
# Slack channel to send the message to
SLACK_CHANNEL = "#server-usage"
# Path to the server list file
SERVER_LIST_FILE = os.path.expanduser("~/utils/server_sync/server_list.txt")
# Path to SSH private key

SSH_KEY_PATH = os.path.expanduser(
    "~/.ssh/server2server"
)  # Adjust if your key is in a different location


def get_ssh_connection(server, username):
    """Establish SSH connection using key-based authentication"""
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        ssh.connect(
            f"{server}.iem.technion.ac.il", username=username, key_filename=SSH_KEY_PATH
        )
        return ssh
    except paramiko.ssh_exception.AuthenticationException:
        print(f"Authentication failed for {server}. Please check your SSH key.")
    except Exception as e:
        print(f"Error connecting to {server}: {e}")
    return None


def get_disk_usage(ssh):
    """Run the df command, filter for /data, and return the output"""
    try:
        stdin, stdout, stderr = ssh.exec_command("df -h | grep /data")
        return stdout.read().decode("utf-8")
    except Exception as e:
        return f"An error occurred while running df: {e}"


def get_detailed_usage(ssh):
    """Run detailed disk usage command for /data/home"""
    try:
        stdin, stdout, stderr = ssh.exec_command(
            "sudo /bin/du -h --max-depth=1 /data/home | sort -h"
        )
        return stdout.read().decode("utf-8")
    except Exception as e:
        return f"An error occurred while running detailed disk usage command: {e}"


def parse_df_output(output, server):
    """Parse df output and return a DataFrame with selected columns"""
    df = pd.read_csv(
        StringIO(output),
        sep=r"\s+",
        names=["Filesystem", "Size", "Used", "Avail", "Use%", "Mounted"],
    )
    df = df[["Size", "Used", "Avail", "Use%"]]
    df["Server"] = server
    df["Use%"] = df["Use%"].str.rstrip("%").astype(int)
    return df[["Server", "Size", "Used", "Avail", "Use%"]]


def send_slack_message(message):
    """Send a message to Slack"""
    client = WebClient(token=SLACK_TOKEN)
    try:
        response = client.chat_postMessage(channel=SLACK_CHANNEL, text=message)
        print(f"Message sent: {response['ts']}")
    except SlackApiError as e:
        print(f"Error sending message: {e}")


def main():
    all_data = []
    high_usage_servers = []
    user = os.getlogin()

    with open(SERVER_LIST_FILE, "r") as file:
        servers = [line.strip() for line in file if not line.startswith("#")]

    for server in servers:
        if ssh := get_ssh_connection(server, user):
            try:
                disk_usage = get_disk_usage(ssh)
                if disk_usage and not disk_usage.startswith("An error occurred"):
                    df = parse_df_output(disk_usage, server)
                    all_data.append(df)

                    if df["Use%"].values[0] > 90:
                        detailed_usage = get_detailed_usage(ssh)
                        high_usage_servers.append((server, detailed_usage))
                else:
                    print(f"No /data partition found or error occurred on {server}")
            except Exception as e:
                print(f"Error getting disk usage from {server}: {e}")
            finally:
                ssh.close()

    if all_data:
        send_formatted_slack_message(all_data, high_usage_servers)
    else:
        print("No data collected from any server.")


def send_formatted_slack_message(all_data, high_usage_servers):
    # Combine all data
    combined_df = pd.concat(all_data, ignore_index=True)

    # Format the table for Slack
    table_str = combined_df.to_string(index=False)

    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    message = f"Disk Usage Report for /data partitions ({current_time}):\n```\n{table_str}\n```"
    send_slack_message(message)

    # Send detailed usage for high usage servers
    for server, detailed_usage in high_usage_servers:
        detailed_message = f"Detailed disk usage for {server} (/data/home):\n```\n{detailed_usage}\n```"
        send_slack_message(detailed_message)


if __name__ == "__main__":
    main()
