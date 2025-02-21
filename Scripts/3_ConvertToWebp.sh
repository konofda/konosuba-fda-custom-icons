#!/bin/bash

# Check if required arguments are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <input_directory> <output_directory> [quality]"
    echo "Example: $0 input_folder output_folder 95"
    exit 1
fi

# Get input and output directories and remove trailing slashes if present
INPUT_DIR=${1%/}
OUTPUT_DIR=${2%/}

# Set quality (default to 90 if not provided)
QUALITY=${3:-90}

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