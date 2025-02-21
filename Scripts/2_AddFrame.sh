#!/bin/bash

# Check if required arguments are provided
if [ $# -lt 2 ]; then
    echo "❌ Error: Both input directory and frame image are required"
    echo "Usage: $0 <input_directory> <frame_image>"
    exit 1
fi

# Get input directory and remove trailing slash if present
INPUT_DIR=${1%/}
FRAME_IMAGE="$2"

# Create output directory name based on input
OUTPUT_DIR="${INPUT_DIR}_WithFrame"

# Create output directory if it doesn't exist
echo "📁 Creating output directory: $OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Check if frame overlay exists
if [ ! -f "$FRAME_IMAGE" ]; then
    echo "❌ Error: Frame image not found: $FRAME_IMAGE"
    exit 1
fi

# Function to process a single image
process_image() {
    input_file="$1"
    filename=$(basename "$input_file")
    output_file="$OUTPUT_DIR/$filename"

    # Create a 512x256 black canvas, place the 486x230 image in center without resizing,
    # then overlay the frame
    convert \
        -size 512x256 xc:black \
        \( "$input_file" -gravity center \) -geometry +0+0 -composite \
        \( "$FRAME_IMAGE" -geometry +0+0 \) -composite \
        "$output_file"
}

export -f process_image
export OUTPUT_DIR
export FRAME_IMAGE

# Process all PNG files in parallel
echo "🖼️  Adding frames to images from $INPUT_DIR using frame: $FRAME_IMAGE"
find "$INPUT_DIR" -name "*.png" | \
    parallel --bar -j$(nproc) process_image {}

echo "✅ Frame addition complete! Output saved to: $OUTPUT_DIR"

