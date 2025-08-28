#!/bin/bash

# Helper script to add new images to the portfolio with metadata extraction
# Usage: ./add-image.sh <category> <image-path> [title] [description]

# Source shared utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/photo-metadata-utils.sh"

if [ $# -lt 2 ] || [ $# -gt 4 ]; then
    echo "Usage: $0 <category> <image-path> [title] [description]"
    echo ""
    echo "Arguments:"
    echo "  category    - Hugo content category (e.g., photography, digital-art)"
    echo "  image-path  - Path to your image file"
    echo "  title       - Optional title (default: auto-generated from filename)"
    echo "  description - Optional description (default: extracted from metadata or empty)"
    echo ""
    echo "Examples:"
    echo "  $0 photography ~/Pictures/my-photo.jpg"
    echo "  $0 photography ~/Pictures/my-photo.jpg 'My Photo Title'"
    echo "  $0 photography ~/Pictures/my-photo.jpg 'My Photo Title' 'Description here'"
    exit 1
fi

CATEGORY=$1
IMAGE_PATH=$2
TITLE=${3:-""}
DESCRIPTION=${4:-""}

# Check if image file exists
if [ ! -f "$IMAGE_PATH" ]; then
    echo "❌ Error: Image file '$IMAGE_PATH' does not exist"
    exit 1
fi

# Check if category directory exists in content
CATEGORY_DIR="content/$CATEGORY"
if [ ! -d "$CATEGORY_DIR" ]; then
    echo "❌ Error: Category directory '$CATEGORY_DIR' does not exist"
    echo "Available categories:"
    ls -1 content/ 2>/dev/null | grep -v "_index.md" || echo "  (none found)"
    exit 1
fi

# Extract original filename and clean it
original_filename=$(basename "$IMAGE_PATH")
clean_filename_output=$(clean_filename "$original_filename")
basename=$(basename "$clean_filename_output" | sed 's/\.[^.]*$//')

# Check if bundle already exists
BUNDLE_DIR="$CATEGORY_DIR/$basename"
if [ -d "$BUNDLE_DIR" ]; then
    echo "⚠️  Warning: Bundle already exists at $BUNDLE_DIR"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Operation cancelled"
        exit 1
    fi
    rm -rf "$BUNDLE_DIR"
fi

# Create bundle directory
mkdir -p "$BUNDLE_DIR"

# Copy image to bundle with cleaned filename
cp "$IMAGE_PATH" "$BUNDLE_DIR/$clean_filename_output"

# Extract photo metadata
echo "📸 Extracting photo metadata..."
if metadata_output=$(extract_photo_metadata "$IMAGE_PATH"); then
    # Use the shared function to parse metadata and generate content
    content_output=$(parse_metadata_and_generate_content "$metadata_output" "$original_filename" "" "$TITLE" "$DESCRIPTION")
    
    # Parse the returned content string using shared function
    parsed_content=$(parse_content_output "$content_output")
    title=$(echo "$parsed_content" | grep -o 'TITLE:[^|]*' | cut -d: -f2)
    description=$(echo "$parsed_content" | grep -o 'DESCRIPTION:[^|]*' | cut -d: -f2)
    date=$(echo "$parsed_content" | grep -o 'DATE:[^|]*' | cut -d: -f2)
    # camera_make=$(echo "$parsed_content" | grep -o 'MAKE:[^|]*' | cut -d: -f2)
    # camera_model=$(echo "$parsed_content" | grep -o 'MODEL:[^|]*' | cut -d: -f2)
    # focal_length=$(echo "$parsed_content" | grep -o 'FOCAL:[^|]*' | cut -d: -f2)
    # f_number=$(echo "$parsed_content" | grep -o 'FNUMBER:[^|]*' | cut -d: -f2)
    # exposure_time=$(echo "$parsed_content" | grep -o 'EXPOSURE:[^|]*' | cut -d: -f2)
    # iso=$(echo "$parsed_content" | grep -o 'ISO:[^|]*' | cut -d: -f2)
    
    # Log what we're using
    echo "🏷️  Title: $title"
    if [ -n "$description" ]; then
        echo "📝 Description: $description"
    else
        echo "📝 No description found - leaving empty"
    fi
    echo "📅 Date: $date"
else
    # Fallback to basic extraction if metadata extraction fails
    if [ -n "$TITLE" ]; then
        title="$TITLE"
    else
        title=$(generate_title "$original_filename")
    fi
    
    if [ -n "$DESCRIPTION" ]; then
        description="$DESCRIPTION"
    else
        description=""
    fi
    
    date=$(date +%Y-%m-%d)
    echo "📅 Date: $date"
fi

# Create content file using shared function
generate_hugo_content "$title" "$description" "$clean_filename_output" "$date" "$camera_make" "$camera_model" "$focal_length" "$f_number" "$exposure_time" "$iso" > "$BUNDLE_DIR/index.md"

echo "✅ Created Page Bundle: $BUNDLE_DIR"
echo "📝 Content file: $BUNDLE_DIR/index.md"
echo "🖼️  Image: $BUNDLE_DIR/$clean_filename_output (renamed from $original_filename)"
echo ""
echo "Next steps:"
echo "1. Review and edit the generated content file"
echo "2. Run 'hugo server' to preview your site"
echo "3. Customize title and description as needed" 