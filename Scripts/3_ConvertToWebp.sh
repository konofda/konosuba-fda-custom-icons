#!/bin/bash

# Check if folder argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <folder_name> [quality]"
    echo "Example: $0 temp1 95"
    exit 1
fi

# Set quality (default to 90 if not provided)
QUALITY=${2:-90}

# Set input and output directories
INPUT_DIR="./$1"
OUTPUT_DIR="./${1}_webp${QUALITY}"

# Check if input directory exists
if [ ! -d "$INPUT_DIR" ]; then
    echo "Error: Input directory $INPUT_DIR does not exist"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Convert files in parallel
find "$INPUT_DIR" -name "*.png" | \
parallel --bar "cwebp -q ${QUALITY} {} -o ${OUTPUT_DIR}/{/.}.webp"

echo "Conversion complete. Files saved to $OUTPUT_DIR"
