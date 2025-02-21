#!/bin/bash

# Check if input directory is provided
if [ $# -lt 1 ]; then
    echo "❌ Error: Input directory is required"
    echo "Usage: $0 <input_directory>"
    exit 1
fi

# Get input directory and remove trailing slash if present
INPUT_DIR=${1%/}

# Create output directory name based on input
OUTPUT_DIR="${INPUT_DIR}_Cropped"

# Create output directory if it doesn't exist
echo "📁 Creating output directory: $OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Process all PNG files in parallel
echo "✂️  Cropping images from $INPUT_DIR"
echo "🔍 Removing 368px from top and 370px from bottom"

find "$INPUT_DIR" -name "*.png" | \
parallel --bar 'convert {} -gravity north -chop 0x368 -gravity south -chop 0x370 \
"$OUTPUT_DIR/{/}"'

echo "✅ Cropping complete! Output saved to: $OUTPUT_DIR"
