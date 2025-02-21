#!/bin/bash

# Check if required arguments are provided
if [ $# -lt 2 ]; then
    echo "❌ Error: Input and output directories are required"
    echo "Usage: $0 <input_directory> <output_directory>"
    exit 1
fi

# Get input and output directories and remove trailing slashes if present
INPUT_DIR=${1%/}
OUTPUT_DIR=${2%/}

# Create output directory if it doesn't exist
echo "📁 Creating output directory: $OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Process all PNG files in parallel
echo "🖼️  Processing images from $INPUT_DIR"
find "$INPUT_DIR" -name "*.png" | \
parallel --bar "convert {} -resize 486x230^ -gravity center -extent 486x230 \
$OUTPUT_DIR/{/}"

echo "✅ Downsizing complete! Output saved to: $OUTPUT_DIR"
