#!/bin/bash

# Configuration
PROJECT_DIR="/Users/nulldivision/Projects/pic-scrape"
IMAGES_DIR="${PROJECT_DIR}/images"

# Check if images directory exists
if [ ! -d "$IMAGES_DIR" ]; then
    echo "Error: Images directory not found at $IMAGES_DIR"
    exit 1
fi

# Find all jpg files in the images directory (recursive)
# We store them in an array to easily pick a random one
# Use null terminator to handle filenames with spaces
IMAGES=()
while IFS= read -r -d '' file; do
    IMAGES+=("$file")
done < <(find "$IMAGES_DIR" -type f -name "*.jpg" -print0)

# Check if we found any images
NUM_IMAGES=${#IMAGES[@]}
if [ "$NUM_IMAGES" -eq 0 ]; then
    echo "Error: No images found in $IMAGES_DIR"
    exit 1
fi

# Pick a random index
RANDOM_INDEX=$((RANDOM % NUM_IMAGES))
SELECTED_IMAGE="${IMAGES[$RANDOM_INDEX]}"

echo "Selected image: $SELECTED_IMAGE"

# Set the wallpaper using AppleScript
# We use osascript to tell Finder to set the desktop picture
osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$SELECTED_IMAGE\""

if [ $? -eq 0 ]; then
    echo "Successfully set wallpaper."
else
    echo "Error: Failed to set wallpaper via AppleScript."
    exit 1
fi
