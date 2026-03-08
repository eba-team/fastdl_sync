#!/bin/bash

# Move into csgo directory if it exists
if [ -d "csgo" ]; then
    cd csgo || exit
fi

# Check parameter
if [ -z "$1" ]; then
    echo "Usage: $0 <server_port>"
    exit 1
fi

PORT="$1"
FASTDL_BASE="/fastdl"
FASTDL_DIR="$FASTDL_BASE/cs_$PORT"

FOLDERS=(
    "expressions"
    "maps"
    "materials"
    "models"
    "panorama"
    "resource"
    "scenes"
    "scripts"
)

# Create FastDL base + server directory if missing
if [ ! -d "$FASTDL_DIR" ]; then
    echo "Creating FastDL directory: $FASTDL_DIR"
    mkdir -p "$FASTDL_DIR"
fi

echo "Using FastDL directory: $FASTDL_DIR"
echo "Starting compression..."

for folder in "${FOLDERS[@]}"; do

    [ -d "$folder" ] || continue

    echo "Processing folder: $folder"

    find "$folder" -type f ! -name "*.bz2" | while read -r file; do

        bz2file="$file.bz2"
        fastdl_bz2="$FASTDL_DIR/$bz2file"

        # Skip if already exists in FastDL
        if [ -f "$fastdl_bz2" ]; then
            echo "Skipping (already in FastDL): $file"
            continue
        fi

        # Compress if bz2 missing
        if [ ! -f "$bz2file" ]; then
            echo "Compressing: $file"
            bzip2 -zk "$file"
        fi

    done

done

echo "Compression finished."

echo "Copying bz2 files to FastDL..."

find . -type f -name "*.bz2" | while read -r file; do

    dest="$FASTDL_DIR/$file"

    # Create destination directory structure
    mkdir -p "$(dirname "$dest")"

    if [ ! -f "$dest" ]; then
        echo "Copying: $file"
        cp "$file" "$dest"
    fi

    # Remove bz2 from server after copying
    rm -f "$file"

done

echo "FastDL sync completed for port $PORT."
