select_device() {
  mapfile -t devices < <(lsblk -lnpo NAME,TYPE | awk '$2=="part"{print $1}')

  if [ ${#devices[@]} -eq 0 ]; then
    echo "$FAILED_ICON No block devices found." >&2
    exit 1
  fi

  echo "🔍 Select a partition:" >&2
  for i in "${!devices[@]}"; do
    echo "$((i + 1))) ${devices[i]}" >&2
  done

  read -rp "Enter choice [1-${#devices[@]}]: " choice

  if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#devices[@]}" ]; then
    echo "$FAILED_ICON "
    exit 0
  fi

  # Only this line will go to stdout and be captured by $(...)
  echo "${devices[$((choice - 1))]}"
}
