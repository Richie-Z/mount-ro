#!/bin/bash

DEVICE="/dev/sdb"
RAW_IMAGE="disk.img"
COMPRESSED_IMAGE="disk.img.gz"
HASH_FILE="disk.img.sha256"

echo "🧠 Choose an option:"
echo "1) Create raw image → then compress and hash"
echo "2) Create compressed image (on-the-fly) and hash immediately"
read -p "Enter choice [1 or 2]: " choice

if [[ "$choice" == "1" ]]; then
    echo "📸 Creating raw image with dd..."
    sudo dd if="$DEVICE" bs=4M status=progress of="$RAW_IMAGE"

    echo "🔐 Hashing raw image..."
    sha256sum "$RAW_IMAGE" | tee "$HASH_FILE"

    echo "📦 Compressing image..."
    gzip -k "$RAW_IMAGE"  # keep raw image

    echo "✅ Done:"
    echo " - Raw image: $RAW_IMAGE"
    echo " - Compressed image: $COMPRESSED_IMAGE"
    echo " - Hash: $HASH_FILE"

elif [[ "$choice" == "2" ]]; then
    echo "📸 Creating compressed image on-the-fly and hashing input..."
    sudo dd if="$DEVICE" bs=4M status=progress | tee >(sha256sum > "$HASH_FILE") | gzip > "$COMPRESSED_IMAGE"

    echo "✅ Done:"
    echo " - Compressed image: $COMPRESSED_IMAGE"
    echo " - Hash saved to: $HASH_FILE"
    echo
    echo "🔁 You can verify later with:"
    echo "gunzip -c $COMPRESSED_IMAGE | sha256sum --check $HASH_FILE"

else
    echo "❌ Invalid choice. Exiting."
    exit 1
fi
