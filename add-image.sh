#!/bin/bash

# Helper script to add new images to the portfolio
# Usage: ./add-image.sh <category> <image-name> <title> <description>

if [ $# -ne 4 ]; then
    echo "Usage: $0 <category> <image-name> <title> <description>"
    echo "Example: $0 photography my-photo 'My Photo Title' 'Description of the photo'"
    exit 1
fi

CATEGORY=$1
IMAGE_NAME=$2
TITLE=$3
DESCRIPTION=$4

# Create the Page Bundle directory and content file
BUNDLE_DIR="content/$CATEGORY/$IMAGE_NAME"
CONTENT_FILE="$BUNDLE_DIR/index.md"
DATE=$(date +%Y-%m-%d)

mkdir -p "$BUNDLE_DIR"

cat > "$CONTENT_FILE" << EOF
---
title: "$TITLE"
description: "$DESCRIPTION"
image: "$IMAGE_NAME.jpg"
additional_images: ["$IMAGE_NAME-2.jpg", "$IMAGE_NAME-3.jpg"]
date: $DATE
---

Add your content here...
EOF

echo "✅ Created Page Bundle: $BUNDLE_DIR"
echo "📝 Edit the file to add your content: $CONTENT_FILE"
echo "🖼️  Add your images to: $BUNDLE_DIR/"
echo "   - Main image: $BUNDLE_DIR/$IMAGE_NAME.jpg"
echo "   - Additional images: $BUNDLE_DIR/$IMAGE_NAME-2.jpg, $BUNDLE_DIR/$IMAGE_NAME-3.jpg"
echo ""
echo "Next steps:"
echo "1. Add your images to $BUNDLE_DIR/"
echo "2. Edit $CONTENT_FILE to add your content"
echo "3. Run 'hugo server' to preview" 