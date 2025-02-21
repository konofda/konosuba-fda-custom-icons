#!/bin/bash

# Check if both input directory and csv file are provided
if [ $# -lt 2 ]; then
    echo "❌ Error: Both input directory and CSV file path are required"
    echo "Usage: $0 <input_directory> <crop_data.csv>"
    exit 1
fi

# Get input directory and remove trailing slash if present
INPUT_DIR=${1%/}
CSV_FILE="$2"

# Create output directory name based on input
OUTPUT_DIR="${INPUT_DIR}_Cropped"

# Check if crop data CSV exists
if [ ! -f "$CSV_FILE" ]; then
    echo "❌ Error: $CSV_FILE not found"
    exit 1
fi

# Create output directory if it doesn't exist
echo "📁 Creating output directory: $OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo "✂️  Processing images from $INPUT_DIR using crop data from $CSV_FILE"

# Skip header line and process CSV
tail -n +2 "$CSV_FILE" | while IFS=, read -r filename top right bottom left; do
    # Remove any quotes from the filename
    filename=$(echo "$filename" | tr -d '"')
    # Create the ImageMagick command
    cmd="convert \"$INPUT_DIR/$filename.png\" -crop +$left+$top -gravity northwest -crop -$right-$bottom \"$OUTPUT_DIR/$filename.png\""
    echo "$cmd"
done | parallel --bar

echo "✅ Cropping complete! Output saved to: $OUTPUT_DIR"