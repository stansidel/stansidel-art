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

# Create the content file
CONTENT_FILE="content/$CATEGORY/$IMAGE_NAME.md"
DATE=$(date +%Y-%m-%d)

cat > "$CONTENT_FILE" << EOF
---
title: "$TITLE"
description: "$DESCRIPTION"
image: "/images/$IMAGE_NAME.jpg"
additional_images: ["/images/$IMAGE_NAME-2.jpg", "/images/$IMAGE_NAME-3.jpg"]
date: $DATE
---

Add your content here...
EOF

echo "✅ Created content file: $CONTENT_FILE"
echo "📝 Edit the file to add your content"
echo "🖼️  Add your image as: static/images/$IMAGE_NAME.jpg"
echo ""
echo "Next steps:"
echo "1. Add your image to static/images/$IMAGE_NAME.jpg"
echo "2. Edit $CONTENT_FILE to add your content"
echo "3. Run 'hugo server' to preview" 