#!/bin/bash

# Script to add contact photo to the static directory
# Usage: ./add-contact-photo.sh /path/to/your/photo.jpg

if [ $# -eq 0 ]; then
    echo "Usage: $0 /path/to/your/photo.jpg"
    echo "This script will copy your photo to the static directory as contact-photo.jpg"
    echo "The photo will be served directly without processing"
    echo ""
    echo "For build-time image processing, manually copy to assets/contact-photo.jpg"
    exit 1
fi

SOURCE_FILE="$1"
TARGET_DIR="static"
TARGET_FILE="$TARGET_DIR/contact-photo.jpg"

# Create static directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Copy the photo
if cp "$SOURCE_FILE" "$TARGET_FILE"; then
    echo "✅ Contact photo copied to $TARGET_FILE"
    echo "The photo will be served directly from the static directory"
    echo ""
    echo "💡 For automatic image optimization, copy to assets/contact-photo.jpg instead"
    echo "   Then update the template to use resources.Get"
else
    echo "❌ Failed to copy photo. Please check the file path and permissions."
    exit 1
fi 