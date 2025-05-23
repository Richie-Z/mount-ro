source utils/compare_hash.sh

create_image() {
    raw_img="disk.img"
    comporessed_img="disk.img.gz"
    hash_file="disk.img.sha256"
    checksum_file="checksum.txt"

    echo "Choose an option:"
    echo "1) Create raw image → then compress and hash"
    echo "2) Create compressed image (on-the-fly) and hash immediately"
    read -rp "Enter choice [1 or 2]: " choice

    if [[ "$choice" == "1" ]]; then
        echo "📸 Creating raw image with dd..."
        if sudo dd if="$DEVICE" bs=4M status=progress of="$raw_img"; then
            echo "$SUCCESS_ICON Raw image created successfully."
        else
            echo "$FAILED_ICON Failed to create raw image."
            return 1
        fi

        echo "Hashing raw image..."
        if sha256sum "$raw_img" | tee "$hash_file"; then
            echo "$SUCCESS_ICON Hash created."
        else
            echo "$FAILED_ICON Hashing failed."
            return 1
        fi

        echo "Compressing image..."
        if gzip -k "$raw_img"; then
            echo "$SUCCESS_ICON Compression done."
        else
            echo "$FAILED_ICON Compression failed."
            return 1
        fi

        echo "$SUCCESS_ICON Done:"
        echo " - Raw image: $raw_img"
        echo " - Compressed image: $comporessed_img"
        echo " - Hash: $hash_file"

    elif [[ "$choice" == "2" ]]; then
        echo "Creating compressed image on-the-fly and hashing input..."
        if sudo dd if="$DEVICE" bs=4M status=progress | tee >(sha256sum >"$hash_file") | gzip >"$comporessed_img"; then
            echo "$SUCCESS_ICON Done:"
            echo " - Compressed image: $comporessed_img"
            echo " - Hash saved to: $hash_file"
            echo
        else
            echo "$FAILED_ICON Failed to create compressed image on-the-fly."
            return 1
        fi

    else
        echo "$FAILED_ICON Invalid choice. Exiting."
        return 1
    fi

    read -rp "Do you want to verify the disk? (y/n): " verify_choice
    if [[ "$verify_choice" =~ ^[Yy]$ ]]; then
        echo "Hashing raw device $DEVICE to create $checksum_file..."
        if sudo sha256sum "$DEVICE" | tee "$checksum_file"; then
            echo "$SUCCESS_ICON Disk verification hash created."
            echo "Comparing raw device hash ($checksum_file) with compressed image hash ($hash_file)..."
            compare_hash "$checksum_file" "$hash_file" "Hash"
        else
            echo "$FAILED_ICON Failed to create disk verification hash."
            return 1
        fi
    fi

}
