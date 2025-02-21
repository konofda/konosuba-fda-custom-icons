#!/bin/bash

# Check if required arguments are provided
if [ $# -lt 2 ]; then
    echo "❌ Error: Input and output directories are required"
    echo "Usage: $0 <input_directory> <output_directory>"
    exit 1
fi

# Get absolute paths for input and output directories and remove trailing slashes
INPUT_DIR=$(realpath "${1%/}")
OUTPUT_DIR=$(realpath "${2%/}")

# Check if input directory exists
if [ ! -d "$INPUT_DIR" ]; then
    echo "❌ Error: Input directory does not exist: $INPUT_DIR"
    exit 1
fi

# Check if ImageMagick is installed
if ! command -v convert >/dev/null 2>&1; then
    echo "❌ Error: ImageMagick is not installed. Please install it first."
    exit 1
fi

# Create output directory if it doesn't exist
echo "📁 Creating output directory: $OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Process all PNG files in parallel
echo "✂️  Cropping images from $INPUT_DIR"
echo "🔍 Removing 368px from top and 370px from bottom"

# Use a more robust parallel command with proper path handling
find "$INPUT_DIR" -name "*.png" -print0 | \
parallel --bar --will-cite -0 \
    'output_file="'"$OUTPUT_DIR"'"/{/}; \
    if [ ! -f "$output_file" ]; then \
        convert {} -gravity north -chop 0x368 -gravity south -chop 0x370 "$output_file" 2>/dev/null || \
        echo "⚠️  Failed to process: {}" >&2; \
    else \
        echo "⏭️  Skipping existing file: {/}" >&2; \
    fi'

# Check if any files were processed
if [ "$(find "$OUTPUT_DIR" -maxdepth 1 -name "*.png" | wc -l)" -eq 0 ]; then
    echo "⚠️  Warning: No files were processed. Check input directory for PNG files."
    exit 1
else
    echo "✅ Cropping complete! Output saved to: $OUTPUT_DIR"
    echo "📊 Total files processed: $(find "$OUTPUT_DIR" -maxdepth 1 -name "*.png" | wc -l)"
fi
