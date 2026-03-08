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
FASTDL_DIR="/var/www/html/fastdl.ebateam.eu/cs_$PORT"

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

echo "Using FastDL directory: $FASTDL_DIR"

mkdir -p "$FASTDL_DIR"

echo "Starting compression..."

for folder in "${FOLDERS[@]}"; do

    if [ ! -d "$folder" ]; then
        continue
    fi

    echo "Processing folder: $folder"

    find "$folder" -type f ! -name "*.bz2" | while read -r file; do

        bz2file="$file.bz2"

        if [ ! -f "$bz2file" ] || [ "$file" -nt "$bz2file" ]; then
            echo "Compressing: $file"
            bzip2 -zkf "$file"
        fi

    done

done

echo "Compression finished."

echo "Copying bz2 files to FastDL..."

find . -type f -name "*.bz2" | while read -r file; do

    dest="$FASTDL_DIR/$file"

    mkdir -p "$(dirname "$dest")"

    # Copy only if new or changed
    if [ ! -f "$dest" ] || [ "$file" -nt "$dest" ]; then
        echo "Copying: $file"
        cp "$file" "$dest"
    fi

    # Remove bz2 from server after copy
    rm -f "$file"

done

echo "FastDL sync completed for port $PORT."
