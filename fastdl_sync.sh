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

echo "Starting FastDL build..."

for folder in "${FOLDERS[@]}"; do

    if [ ! -d "$folder" ]; then
        continue
    fi

    echo "Processing folder: $folder"

    find "$folder" -type f ! -name "*.bz2" | while read file; do

        bz2file="$file.bz2"

        if [ ! -f "$bz2file" ] || [ "$file" -nt "$bz2file" ]; then
            echo "Compressing: $file"
            bzip2 -zkf "$file"
        fi

    done

done

echo "Compression finished."

echo "Moving bz2 files to FastDL..."

rsync -av \
--include="*/" \
--include="*.bz2" \
--exclude="*" \
--remove-source-files \
./ "$FASTDL_DIR/"

echo "FastDL sync completed for server port $PORT."
