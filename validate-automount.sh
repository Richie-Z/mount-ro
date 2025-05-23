#!/bin/bash

DEVICE="/dev/sdb"
PARTITION="${DEVICE}1"  # Adjust this to match your actual partition
MOUNTPOINT="/mnt/testdisk"
IMAGE1="disk_before.img"
IMAGE2="disk_after.img"

SKIP_TO_MOUNT=0

# Check for "cheat" flag
if [[ "$1" == "--skip" ]]; then
    SKIP_TO_MOUNT=1
    echo "⚠️  Cheat mode enabled: Skipping to Step 4 (mounting)..."
fi

if [[ "$SKIP_TO_MOUNT" -eq 0 ]]; then
    # Step 1: Hash the raw device (before mounting)
    echo "[1] Hashing raw device before mounting..."
    sudo sha256sum "$DEVICE" | tee checksum.txt

    # Step 2: Create image before mounting
    echo "[2] Creating image of device before mounting..."
    sudo dd if="$DEVICE" of="$IMAGE1" bs=4M status=progress
    sha256sum "$IMAGE1" | tee disk_before.txt

    # Step 3: Compare hash from device and image
    echo "[3] Comparing checksum.txt and disk_before.txt..."
    if cmp -s <(cut -d ' ' -f1 checksum.txt) <(cut -d ' ' -f1 disk_before.txt); then
        echo "✅ Hashes match BEFORE mounting."
    else
        echo "❌ Hashes DO NOT match BEFORE mounting!"
    fi
fi

# Step 4: Mount the device partition (not the raw device!)
echo "[4] Mounting the device partition..."
sudo mkdir -p "$MOUNTPOINT"
if sudo mount "$PARTITION" "$MOUNTPOINT"; then
    echo "✅ Mounted $PARTITION to $MOUNTPOINT"
else
    echo "❌ Failed to mount $PARTITION"
    exit 1
fi

# Optional pause to simulate auto-access
echo "Waiting for 5 seconds to simulate auto-access..."
sleep 5

# Step 5: Create image after mounting
echo "[5] Creating image of device after mounting..."
sudo dd if="$DEVICE" of="$IMAGE2" bs=4M status=progress
sha256sum "$IMAGE2" | tee disk_after.txt

# Step 6: Compare hash before and after mount
echo "[6] Comparing disk_before.txt and disk_after.txt..."
if cmp -s <(cut -d ' ' -f1 disk_before.txt) <(cut -d ' ' -f1 disk_after.txt); then
    echo "✅ Disk image remains unchanged AFTER mounting."
else
    echo "❌ Disk image CHANGED after mounting!"
fi

# Cleanup
echo "[!] Unmounting and cleaning up..."
sudo umount "$MOUNTPOINT"
sudo rmdir "$MOUNTPOINT"
