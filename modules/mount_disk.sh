mount_disk() {
    echo
    echo "Choose how you want to mount the disk:"
    echo "1) Normal Mount"
    echo "2) Read-Only Mount ($SUCCESS_ICON forensic safe using blockdev)"
    read -rp "Enter choice [1 or 2]: " choice

    sudo mkdir -p "$MOUNTPOINT"

    if [[ "$choice" == "1" ]]; then
        echo "Mounting normally (read-write if allowed)..."
        sudo mount "$PARTITION" "$MOUNTPOINT" && echo "$SUCCESS_ICON Mounted at $MOUNTPOINT" || echo "$FAILED_ICON Failed to mount."

    elif [[ "$choice" == "2" ]]; then
        echo "Setting device to read-only on block-level"
        sudo blockdev --setro "$DEVICE"

        if [[ "$(sudo blockdev --getro "$DEVICE")" == "1" ]]; then
            echo "$SUCCESS_ICON Device is now in read-only mode."
            echo "Mounting the partition with -o ro..."
            sudo mount -o ro "$PARTITION" "$MOUNTPOINT" && echo "$SUCCESS_ICON Mounted read-only at $MOUNTPOINT" || echo "$FAILED_ICON Failed to mount."
        else
            echo "$FAILED_ICON Failed to set read-only mode with blockdev."
        fi

    else
        echo "$FAILED_ICON Invalid choice. Exiting."
        return 1
    fi

    echo
    echo "Current mount status:"
    mount | grep "$PARTITION"
}
