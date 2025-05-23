#!/bin/bash

DEVICE="/dev/sdb"
PARTITION="${DEVICE}1"
MOUNTPOINT="/mnt/forensic_mount"
HASH_BEFORE="hash_before.txt"
HASH_AFTER="hash_after.txt"

# Parse argument
SKIP_HASH=false
if [[ "$1" == "--skip" ]]; then
    SKIP_HASH=true
fi

# Hash the raw device before mounting
if ! $SKIP_HASH; then
    echo "🔎 Hashing $DEVICE before mount..."
    sudo sha256sum "$DEVICE" | tee "$HASH_BEFORE"
else
    echo "⏭️ Skipping hash step as requested with --skip"
fi

# Ask user for mount mode
echo
echo "🧠 Choose how you want to mount the disk:"
echo "1) Normal Mount (⚠️ not safe for forensics)"
echo "2) True Read-Only Mount (✅ forensic safe using blockdev)"
read -p "Enter choice [1 or 2]: " choice

# Create mountpoint if not exists
sudo mkdir -p "$MOUNTPOINT"

if [[ "$choice" == "1" ]]; then
    echo "🔧 Mounting normally (read-write if allowed)..."
    sudo mount "$PARTITION" "$MOUNTPOINT" && echo "✅ Mounted at $MOUNTPOINT" || echo "❌ Failed to mount."

elif [[ "$choice" == "2" ]]; then
    echo "🔐 Setting device to read-only using blockdev..."
    sudo blockdev --setro "$DEVICE"
    
    if [[ "$(sudo blockdev --getro $DEVICE)" == "1" ]]; then
        echo "✅ Device is now in read-only mode."
        echo "🔧 Mounting with -o ro..."
        sudo mount -o ro "$PARTITION" "$MOUNTPOINT" && echo "✅ Mounted read-only at $MOUNTPOINT" || echo "❌ Failed to mount."
    else
        echo "❌ Failed to set read-only mode with blockdev."
    fi

else
    echo "❌ Invalid choice. Exiting."
    exit 1
fi

# Optional: pause to simulate time/mount activity
echo
echo "🕒 Waiting 5 seconds to simulate possible changes..."
sleep 5

# Hash the raw device again after mounting
if ! $SKIP_HASH; then
    echo
    echo "🔎 Hashing $DEVICE after mount..."
    sudo sha256sum "$DEVICE" | tee "$HASH_AFTER"

    # Compare the hashes
    echo
    echo "🔁 Comparing hashes before and after mount..."
    if cmp -s <(cut -d ' ' -f1 "$HASH_BEFORE") <(cut -d ' ' -f1 "$HASH_AFTER"); then
        echo "✅ No changes detected. Hashes MATCH."
    else
        echo "❌ WARNING: Hashes DIFFER! The disk may have been modified."
    fi
fi

# Print mount info
echo
echo "🧾 Current mount status:"
mount | grep "$PARTITION"

