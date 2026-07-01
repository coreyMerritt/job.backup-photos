#!/bin/bash

set -euo pipefail

# Variables
script_dir="$(dirname "$(readlink -f "$0")")"
script_name="backup-photos.sh"
script_log_name="$(echo $script_name | sed 's|.sh|.log|g')"
cron_job_definition="0 2 * * 0 ${script_dir}/${script_name} >> ${script_dir}/${script_log_name} 2>&1"
current_cronjobs=$(sudo crontab -l 2>/dev/null || true)
filtered_cronjobs=$(echo "$current_cronjobs" | grep -Fv "$script_name" || true)

# Functions
function info() {
  msg="$1"
  datetime="$(date +"%Y-%m-%d %H:%M:%S.%3N %Z")"
  light_blue="\033[38;2;91;91;255m"
  white="\033[0m"
  echo -e "[$datetime] [${light_blue}INFO${white}]  $msg"
}

# Execute
if echo "$current_cronjobs" | grep -Fq "$script_name"; then
  info "Found existing job(s) referencing '$script_name':"
  echo "$current_cronjobs" | grep -F "$script_name"
  info "Removing and replacing with the correct job..."
else
  info "No existing job referencing '$script_name' found. Adding it fresh..."
fi

if [ -z "$filtered_cronjobs" ]; then
  echo "$cron_job_definition" | sudo crontab -
else
  (echo "$filtered_cronjobs"; echo "$cron_job_definition") | sudo crontab -
fi

info "Done. Current crontab:"
sudo crontab -l
