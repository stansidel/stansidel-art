#!/bin/bash

# Batch photo upload script for multiple categories
# Usage: ./batch-upload.sh <config-file>

if [ $# -ne 1 ]; then
    echo "Usage: $0 <config-file>"
    echo ""
    echo "Create a config file with the following format:"
    echo "CATEGORY:photos-directory:title-prefix"
    echo ""
    echo "Example config file (batch-config.txt):"
    echo "photography:~/Pictures/portfolio:Photography"
    echo "digital-art:~/Artwork/abstract:Abstract Art"
    echo "photography:~/Pictures/street:Street Photography"
    echo ""
    echo "Then run: $0 batch-config.txt"
    exit 1
fi

CONFIG_FILE="$1"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: Config file '$CONFIG_FILE' does not exist"
    exit 1
fi

echo "🚀 Starting batch photo upload..."
echo "📋 Config file: $CONFIG_FILE"
echo ""

# Check if add-multiple-photos.sh exists
if [ ! -f "add-multiple-photos.sh" ]; then
    echo "❌ Error: add-multiple-photos.sh script not found"
    echo "Please make sure it's in the same directory"
    exit 1
fi

# Process each line in config file
LINE_NUMBER=0
TOTAL_PROCESSED=0

while IFS= read -r line; do
    ((LINE_NUMBER++))
    
    # Skip empty lines and comments
    if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
        continue
    fi
    
    # Parse the line (category:directory:prefix)
    IFS=':' read -r category directory prefix <<< "$line"
    
    # Trim whitespace
    category=$(echo "$category" | xargs)
    directory=$(echo "$directory" | xargs)
    prefix=$(echo "$prefix" | xargs)
    
    # Validate required fields
    if [[ -z "$category" || -z "$directory" ]]; then
        echo "⚠️  Warning: Skipping line $LINE_NUMBER - invalid format: $line"
        continue
    fi
    
    echo "📸 Processing category: $category"
    echo "   📁 Directory: $directory"
    if [ -n "$prefix" ]; then
        echo "   🏷️  Prefix: $prefix"
    fi
    echo ""
    
    # Run the add-multiple-photos script
    if [ -n "$prefix" ]; then
        ./add-multiple-photos.sh "$category" "$directory" "$prefix"
    else
        ./add-multiple-photos.sh "$category" "$directory"
    fi
    
    if [ $? -eq 0 ]; then
        echo "✅ Successfully processed category: $category"
        ((TOTAL_PROCESSED++))
    else
        echo "❌ Failed to process category: $category"
    fi
    
    echo ""
    echo "──────────────────────────────────────────────────"
    echo ""
    
done < "$CONFIG_FILE"

echo "🎉 Batch upload completed!"
echo "✅ Successfully processed: $TOTAL_PROCESSED category(ies)"
echo ""
echo "Next steps:"
echo "1. Review all generated content files"
echo "2. Run 'hugo server' to preview your site"
echo "3. Customize titles and descriptions as needed"
