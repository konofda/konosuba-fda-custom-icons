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
OUTPUT_DIR="${INPUT_DIR}_Downsized"

# Create output directory if it doesn't exist
echo "📁 Creating output directory: $OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Process all PNG files in parallel
echo "🖼️  Processing images from $INPUT_DIR"
find "$INPUT_DIR" -name "*.png" | \
parallel --bar "convert {} -resize 486x230^ -gravity center -extent 486x230 \
$OUTPUT_DIR/{/}"

echo "✅ Downsizing complete! Output saved to: $OUTPUT_DIR"
