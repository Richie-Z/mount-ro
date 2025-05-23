source utils/compare_hash.sh

validate_automount() {
    image1="disk_before.img"
    image2="disk_after.img"

    echo "[1] Hashing raw device before mounting..."
    sudo sha256sum "$DEVICE" | tee checksum.txt

    echo "[2] Creating image of device before mounting..."
    sudo dd if="$DEVICE" of="$image1" bs=4M status=progress
    sha256sum "$image1" | tee disk_before.txt

    echo "[3] Comparing checksum.txt and disk_before.txt..."
    compare_hashes checksum.txt disk_before.txt "Hashes"

    echo "[4] Mounting the device partition..."
    sudo mkdir -p "$MOUNTPOINT"
    if sudo mount "$PARTITION" "$MOUNTPOINT"; then
        echo "$SUCCESS_ICON Mounted $PARTITION to $MOUNTPOINT"
    else
        echo "$FAILED_ICON Failed to mount $PARTITION"
        exit 1
    fi

    echo "Waiting for 5 seconds to simulate auto-access..."
    sleep 5

    echo "[5] Creating image of device after mounting..."
    sudo dd if="$DEVICE" of="$image2" bs=4M status=progress
    sha256sum "$image2" | tee disk_after.txt

    echo "[6] Comparing disk_before.txt and disk_after.txt..."
    compare_hashes disk_before.txt disk_after.txt "Disk image BEFORE and AFTER mounting"

    echo "[!] Unmounting and cleaning up..."
    sudo umount "$MOUNTPOINT"
    sudo rmdir "$MOUNTPOINT"
}
