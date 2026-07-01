#!/usr/bin/env bash

set -euo pipefail

# Constants
mount_point="/mnt/ukko-pixel-10-pro"
camera="${mount_point}/DCIM/Camera"
messages_pictures="${mount_point}/Pictures/Messages"
screenshots="${mount_point}/Pictures/Screenshots"
landing_photos="/mnt/Media-WD-B01LG78D/pictures/photos"
landing_screenshots="/mnt/Media-WD-B01LG78D/pictures/screenshots"
landing_videos="/mnt/Media-WD-B01LG78D/videos/.personal"
picture_extensions=(
  "jpg"
  "jpeg"
  "png"
  "heic"
)
video_extensions=(
  "mp4"
  "mov"
)


# Assertions
[[ -n "$(ls -A "$mount_point" 2>/dev/null)" ]]
[[ -n "$(ls -A "$camera" 2>/dev/null)" ]]
[[ -n "$(ls -A "$messages_pictures" 2>/dev/null)" ]]
[[ -n "$(ls -A "$screenshots" 2>/dev/null)" ]]
ls "$landing_photos" 1>&2>/dev/null
ls "$landing_screenshots" 1>&2>/dev/null

# Functions
function debug() {
  msg="$1"
  datetime="$(date +"%Y-%m-%d %H:%M:%S.%3N %Z")"
  echo -e "[$datetime] [DEBUG] $msg"
}

function info() {
  msg="$1"
  datetime="$(date +"%Y-%m-%d %H:%M:%S.%3N %Z")"
  light_blue="\033[38;2;91;91;255m"
  white="\033[0m"
  echo -e "[$datetime] [${light_blue}INFO${white}]  $msg"
}

function error() {
  msg="$1"
  datetime="$(date +"%Y-%m-%d %H:%M:%S.%3N %Z")"
  red="\033[38;2;255;0;0m"
  white="\033[0m"
  echo -e "[$datetime] [${red}Error${white}] $msg"
}

function route_file() {
  file_path="$1"
  is_screenshot="$2"
  file_name="$(basename "$file_path")"
  new_file_name="${filesystem_datetime}--${file_name}"
  file_extension="${file_name##*.}"
  if [[ "$is_screenshot" == "true" ]]; then
    if [[ " ${picture_extensions[*]} " == *" ${file_extension,,} "* ]]; then
      handle_screenshot
    else
      error "Found a screenshot that is not a picture: ${file_name}"
      exit 1
    fi
  elif [[ "$is_screenshot" == "false" ]]; then
    if [[ " ${picture_extensions[*]} " == *" ${file_extension,,} "* ]]; then
      handle_picture
    elif [[ " ${video_extensions[*]} " == *" ${file_extension,,} "* ]]; then
      handle_video
    else
      error "Unknown file extension: ${file_extension}"
      exit 1
    fi
  else
    error "Bad value for is_screenshot: ${is_screenshot}"
    exit 1
  fi
}

function handle_screenshot() {
  new_file_path="${landing_screenshots}/${new_file_name}"
  if ls -l "$landing_screenshots" | grep "$file_name" 1>&2>/dev/null; then
    debug "Screenshot already exists. Skipping: $file_name"
  else
    info "Executing Copy: ${file_path} -> ${new_file_path}"
    cp "$file_path" "$new_file_path"
  fi
}

function handle_picture() {
  new_file_path="${landing_photos}/${new_file_name}"
  if ls -l "$landing_photos" | grep "$file_name" 1>&2>/dev/null; then
    debug "Picture already exists. Skipping: $file_name"
  else
    info "Executing Copy: ${file_path} -> ${new_file_path}"
    cp "$file_path" "$new_file_path"
  fi
}

function handle_video() {
  new_file_path="${landing_videos}/${new_file_name}"
  if ls -l "$landing_videos" | grep "$file_name" 1>&2>/dev/null; then
    debug "Video already exists. Skipping: $file_name"
  else
    info "Executing Copy: ${file_path} -> ${new_file_path}"
    cp "$file_path" "$new_file_path"
  fi
}

# Setup
filesystem_datetime="$(date +"%Y-%m-%d_%H-%M-%S")"

# Execute
screenshot_files=("$screenshots"/*)
for file_path in "${screenshot_files[@]}"; do
  route_file "$file_path" "true"
done

camera_files=("$camera"/*)
for file_path in "${camera_files[@]}"; do
  route_file "$file_path" "false"
done

messages_picture_files=("$messages_pictures"/*)
for file_path in "${messages_picture_files[@]}"; do
  route_file "$file_path" "false"
done
