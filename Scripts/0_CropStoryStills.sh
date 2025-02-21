#!/bin/bash

# Check if all required arguments are provided
if [ $# -lt 3 ]; then
    echo "❌ Error: Input directory, output directory, and CSV file path are required"
    echo "Usage: $0 <input_directory> <output_directory> <crop_data.csv>"
    exit 1
fi

# Get absolute paths and remove trailing slashes
INPUT_DIR=$(realpath "${1%/}")
OUTPUT_DIR=$(realpath "${2%/}")
CSV_FILE=$(realpath "$3")

# Check if input directory exists
if [ ! -d "$INPUT_DIR" ]; then
    echo "❌ Error: Input directory does not exist: $INPUT_DIR"
    exit 1
fi

# Check if crop data CSV exists
if [ ! -f "$CSV_FILE" ]; then
    echo "❌ Error: Crop data file not found: $CSV_FILE"
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

echo "✂️  Processing images from $INPUT_DIR"
echo "📄 Using crop data from $CSV_FILE"

# Process CSV and create commands
process_count=0
error_count=0

# Skip header line and process CSV
tail -n +2 "$CSV_FILE" | while IFS=, read -r filename top right bottom left; do
    # Remove any quotes from the filename
    filename=$(echo "$filename" | tr -d '"')
    input_file="$INPUT_DIR/$filename.png"
    output_file="$OUTPUT_DIR/$filename.png"
    
    # Skip if output already exists
    if [ -f "$output_file" ]; then
        echo "⏭️  Skipping existing file: $filename.png" >&2
        continue
    fi
    
    # Check if input file exists
    if [ ! -f "$input_file" ]; then
        echo "⚠️  Input file not found: $filename.png" >&2
        continue
    fi
    
    echo "convert \"$input_file\" -crop +$left+$top -gravity northwest -crop -$right-$bottom \"$output_file\""
done | parallel --bar --will-cite \
    "eval {} 2>/dev/null || echo \"⚠️  Failed to process: {}\""

# Check if any files were processed
processed_files=$(find "$OUTPUT_DIR" -maxdepth 1 -name "*.png" | wc -l)

if [ "$processed_files" -eq 0 ]; then
    echo "⚠️  Warning: No files were processed. Check input directory and CSV file."
    exit 1
else
    echo "✅ Cropping complete! Output saved to: $OUTPUT_DIR"
    echo "📊 Total files processed: $processed_files"
fi