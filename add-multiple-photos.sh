#!/bin/bash

# Bulk photo upload script for Hugo portfolio
# Usage: ./add-multiple-photos.sh <category> <photos-directory> [title-prefix]

# Source shared utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/photo-metadata-utils.sh"

if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    echo "Usage: $0 <category> <photos-directory> [title-prefix]"
    echo ""
    echo "Arguments:"
    echo "  category        - Hugo content category (e.g., photography, digital-art)"
    echo "  photos-directory - Directory containing your photos"
    echo "  title-prefix    - Optional prefix for photo titles (default: auto-generated)"
    echo ""
    echo "Examples:"
    echo "  $0 photography ~/Pictures/portfolio"
    echo "  $0 digital-art ~/Artwork/abstract 'Abstract Art'"
    echo ""
    echo "Supported image formats: jpg, jpeg, png, gif, webp, svg"
    exit 1
fi

CATEGORY=$1
PHOTOS_DIR=$2
TITLE_PREFIX=${3:-""}

# Check if photos directory exists
if [ ! -d "$PHOTOS_DIR" ]; then
    echo "❌ Error: Photos directory '$PHOTOS_DIR' does not exist"
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

# Supported image extensions
IMAGE_EXTENSIONS=("jpg" "jpeg" "png" "gif" "webp" "svg")

# Function to check if file is an image
is_image() {
    local file="$1"
    local ext="${file##*.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    
    for supported_ext in "${IMAGE_EXTENSIONS[@]}"; do
        if [ "$ext" = "$supported_ext" ]; then
            return 0
        fi
    done
    return 1
}

# Function to generate title from filename
generate_title() {
    local filename="$1"
    local basename=$(basename "$filename" | sed 's/\.[^.]*$//')
    
    # Convert dashes and underscores to spaces, then capitalize
    local title=$(echo "$basename" | sed 's/[-_]/ /g' | sed 's/\b\w/\U&/g')
    
    if [ -n "$TITLE_PREFIX" ]; then
        title="$TITLE_PREFIX - $title"
    fi
    
    echo "$title"
}

# Function to generate description from title
generate_description() {
    local title="$1"
    echo "A beautiful piece of $CATEGORY: $title"
}

# Find all image files
echo "🔍 Scanning for images in $PHOTOS_DIR..."
IMAGE_FILES=()
while IFS= read -r -d '' file; do
    if is_image "$file"; then
        IMAGE_FILES+=("$file")
    fi
done < <(find "$PHOTOS_DIR" -type f -print0)

if [ ${#IMAGE_FILES[@]} -eq 0 ]; then
    echo "❌ No supported image files found in $PHOTOS_DIR"
    echo "Supported formats: ${IMAGE_EXTENSIONS[*]}"
    exit 1
fi

echo "✅ Found ${#IMAGE_FILES[@]} image(s)"
echo ""

# Process each image
PROCESSED_COUNT=0
SKIPPED_COUNT=0

for image_file in "${IMAGE_FILES[@]}"; do
    original_filename=$(basename "$image_file")
    clean_filename_output=$(clean_filename "$original_filename")
    basename=$(basename "$clean_filename_output" | sed 's/\.[^.]*$//')
    
    # Check if bundle already exists
    BUNDLE_DIR="$CATEGORY_DIR/$basename"
    if [ -d "$BUNDLE_DIR" ]; then
        echo "⚠️  Skipping $original_filename - bundle already exists at $BUNDLE_DIR"
        ((SKIPPED_COUNT++))
        continue
    fi
    
    # Create bundle directory
    mkdir -p "$BUNDLE_DIR"
    
    # Copy image to bundle with cleaned filename
    cp "$image_file" "$BUNDLE_DIR/$clean_filename_output"
    
    # Extract photo metadata
    echo "   📸 Extracting photo metadata..."
    if metadata_output=$(extract_photo_metadata "$image_file"); then
        # Use the shared function to parse metadata and generate content
        content_output=$(parse_metadata_and_generate_content "$metadata_output" "$original_filename" "$TITLE_PREFIX")
        
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
        echo "   🏷️  Title: $title"
        if [ -n "$description" ]; then
            echo "   📝 Description: $description"
        else
            echo "   📝 No description found - leaving empty"
        fi
        echo "   📅 Date: $date"
    else
        # Fallback to basic extraction if metadata extraction fails
        title=$(generate_title "$original_filename")
        if [ -n "$TITLE_PREFIX" ]; then
            title="$TITLE_PREFIX - $title"
        fi
        description=""
        
        if extracted_date=$(extract_date_from_filename "$original_filename"); then
            date="$extracted_date"
        else
            date=$(date +%Y-%m-%d)
        fi
    fi
    
    # Create content file using shared function
    generate_hugo_content "$title" "$description" "$clean_filename_output" "$date" "$camera_make" "$camera_model" "$focal_length" "$f_number" "$exposure_time" "$iso" > "$BUNDLE_DIR/index.md"    
    echo "✅ Created bundle for $original_filename"
    echo "   📁 Directory: $BUNDLE_DIR"
    echo "   📝 Content: $BUNDLE_DIR/index.md"
    echo "   🖼️  Image: $BUNDLE_DIR/$clean_filename_output (renamed from $original_filename)"
    echo ""
    
    ((PROCESSED_COUNT++))
done

# Summary
echo "🎉 Bulk upload completed!"
echo "✅ Successfully processed: $PROCESSED_COUNT photo(s)"
if [ $SKIPPED_COUNT -gt 0 ]; then
    echo "⚠️  Skipped (already exists): $SKIPPED_COUNT photo(s)"
fi
echo ""
echo "Next steps:"
echo "1. Review and edit the generated content files"
echo "2. Run 'hugo server' to preview your site"
echo "3. Customize titles and descriptions as needed"
echo ""
echo "💡 Tip: You can run this script multiple times on the same directory"
echo "   It will skip photos that already have bundles created"
