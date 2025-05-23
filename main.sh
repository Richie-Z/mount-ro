#!/bin/bash

SUCCESS_ICON="✅"
FAILED_ICON="❌"

source utils/select_device.sh
source modules/validate_automount.sh
source modules/mount_disk.sh
source modules/create_image.sh

ascii_art=$(
  cat <<'EOF'
⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠟⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢷⡄⠈⡓⠢⢄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⠤⠂⢹
⠈⡷⡄⠈⠲⢤⣈⠻⠉⠛⠉⠉⠁⠒⠖⠉⠉⠉⠒⠶⢦⣤⠴⠒⢉⣡⢴⠀⠀⠀
⠀⢸⡿⡂⠀⠀⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⣴⡞⠉⠀⢀⣠⡞⠀
⠀⠀⢙⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⠀⢠⡼⡟⠀⠀
⠀⠀⡼⠋⠀⣤⣀⠀⠀⠀⠀⠀⠈⠐⣂⣄⠀⠀⠀⠀⠀⠀⠀⢀⠀⣰⡟⠁⠀⠀
⠀⢠⡇⠀⠀⠘⠛⠃⠀⠀⠀⠀⠾⣿⠿⠟⠉⠀⠀⠀⠀⠀⠀⠀⠀⢻⠀⠀⠀⠀
⠀⢸⡇⢺⡀⠀⢠⡒⠠⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⡀⠀⠀⠸⡇⠀⠀⠀
⠀⢸⡇⣘⠑⡀⠀⠙⢏⣁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠂⠀⣔⣇⠀⠀⠀
⠀⢸⡇⡁⠀⢳⣶⣾⣷⣦⣄⣀⡀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀
⠀⠸⡇⠁⠀⠀⢏⠉⠀⠀⠙⠛⠛⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⢈⡏⠀⠀⠀
⠀⠀⠯⣀⣈⣀⣈⣐⣲⣄⣄⣤⣴⣆⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣈⣛⡧⠀⠀⠀
EOF
)

info_text=$(
  cat <<'EOF'
  
  
        Digital Forensics Hack #1
        Mount media in read-only mode
        This script is based on my personal hack on this topic
        I assume you already turn-off the auto-mount feature
EOF
)

paste <(echo "$ascii_art") <(echo "$info_text")
echo

PARTITION=$(select_device)
if [[ "${PARTITION:0:1}" == "$FAILED_ICON" ]]; then
  echo
  echo "WASTED"
  echo "Pick the right choice you silly!"
  exit 0
fi
DEVICE="${PARTITION%?}"

echo
echo "$SUCCESS_ICON Selected Device: $DEVICE"
echo "$SUCCESS_ICON Selected Partition: $PARTITION"

DEFAULT_MOUNTPOINT="/mnt/forensic"
read -rp "Enter mount point name [default: $DEFAULT_MOUNTPOINT]: " USER_INPUT
MOUNTPOINT="${USER_INPUT:-$DEFAULT_MOUNTPOINT}"
echo "$SUCCESS_ICON Selected Mountpoint: $MOUNTPOINT"

echo
echo "Menu: "
echo "============================"
echo "1) Verify why auto-mounting is bad"
echo "2) Mounting device in read-only mode"
echo "3) Create image from disk (pre/post mount)"
read -rp "Enter choice [1-3]: " CHOICE

case "$CHOICE" in
1)
  validate_automount
  ;;
2)
  mount_disk
  ;;
3)
  create_image
  ;;
*)
  echo "$FAILED_ICON Invalid option!"
  echo "Can you read?"
  ;;
esac
