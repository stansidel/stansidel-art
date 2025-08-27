#!/bin/bash

# Bulk photo upload script for Hugo portfolio
# Usage: ./add-multiple-photos.sh <category> <photos-directory> [title-prefix]

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

# Function to extract date from filename
extract_date_from_filename() {
    local filename="$1"
    local basename=$(basename "$filename" | sed 's/\.[^.]*$//')
    
    # Try to match YYYYMMDD format (8 digits at the beginning)
    if [[ "$basename" =~ ^([0-9]{8}) ]]; then
        local date_str="${BASH_REMATCH[1]}"
        local year="${date_str:0:4}"
        local month="${date_str:4:2}"
        local day="${date_str:6:2}"
        
        # Validate date components
        if [[ "$month" -ge 1 && "$month" -le 12 && "$day" -ge 1 && "$day" -le 31 ]]; then
            echo "${year}-${month}-${day}"
            return 0
        fi
    fi
    
    # Try to match YYMMDD format (6 digits at the beginning)
    if [[ "$basename" =~ ^([0-9]{6}) ]]; then
        local date_str="${BASH_REMATCH[1]}"
        local year="${date_str:0:2}"
        local month="${date_str:2:2}"
        local day="${date_str:4:2}"
        
        # Validate date components
        if [[ "$month" -ge 1 && "$month" -le 12 && "$day" -ge 1 && "$day" -le 31 ]]; then
            # Assume 20xx for years (you can modify this logic if needed)
            echo "20${year}-${month}-${day}"
            return 0
        fi
    fi
    
    # No valid date found
    return 1
}

# Function to extract photo metadata using exiftool
extract_photo_metadata() {
    local image_file="$1"
    
    # Check if exiftool is available
    if ! command -v exiftool &> /dev/null; then
        echo "⚠️  exiftool not found - metadata extraction disabled"
        return 1
    fi
    
    # Extract metadata fields individually
    local title=$(exiftool -Title -b "$image_file" 2>/dev/null)
    local description=$(exiftool -Description -b "$image_file" 2>/dev/null)
    local caption=$(exiftool -Caption-Abstract -b "$image_file" 2>/dev/null)
    local make=$(exiftool -Make -b "$image_file" 2>/dev/null)
    local model=$(exiftool -"Camera Model Name" -b "$image_file" 2>/dev/null)
    local focal_length=$(exiftool -FocalLength -b "$image_file" 2>/dev/null)
    local f_number=$(exiftool -FNumber -b "$image_file" 2>/dev/null)
    local exposure_time=$(exiftool -ExposureTime -b "$image_file" 2>/dev/null)
    local metering_mode=$(exiftool -MeteringMode -b "$image_file" 2>/dev/null)
    local iso=$(exiftool -ISO -b "$image_file" 2>/dev/null)
    local date_time=$(exiftool -DateTimeOriginal -b "$image_file" 2>/dev/null)
    
    # Return metadata as a structured string
    echo "TITLE:$title|DESCRIPTION:$description|CAPTION:$caption|MAKE:$make|MODEL:$model|FOCAL:$focal_length|FNUMBER:$f_number|EXPOSURE:$exposure_time|METERING:$metering_mode|ISO:$iso|DATETIME:$date_time"
}

# Function to clean filename (replace special chars with underscores)
clean_filename() {
    local filename="$1"
    local basename=$(basename "$filename" | sed 's/\.[^.]*$//')
    local extension="${filename##*.}"
    
    # Replace special characters with underscores, then consolidate consecutive underscores
    local clean_name=$(echo "$basename" | sed 's/[^a-zA-Z0-9]/_/g' | sed 's/__*/_/g' | sed 's/^_//' | sed 's/_$//')
    
    # If clean name is empty, use a default
    if [ -z "$clean_name" ]; then
        clean_name="image"
    fi
    
    echo "${clean_name}.${extension}"
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
        # Parse metadata string (key:value|key:value format)
        photo_title=$(echo "$metadata_output" | grep -o 'TITLE:[^|]*' | cut -d: -f2)
        photo_description=$(echo "$metadata_output" | grep -o 'DESCRIPTION:[^|]*' | cut -d: -f2)
        photo_caption=$(echo "$metadata_output" | grep -o 'CAPTION:[^|]*' | cut -d: -f2)
        camera_make=$(echo "$metadata_output" | grep -o 'MAKE:[^|]*' | cut -d: -f2)
        camera_model=$(echo "$metadata_output" | grep -o 'MODEL:[^|]*' | cut -d: -f2)
        focal_length=$(echo "$metadata_output" | grep -o 'FOCAL:[^|]*' | cut -d: -f2)
        f_number=$(echo "$metadata_output" | grep -o 'FNUMBER:[^|]*' | cut -d: -f2)
        exposure_time=$(echo "$metadata_output" | grep -o 'EXPOSURE:[^|]*' | cut -d: -f2)
        metering_mode=$(echo "$metadata_output" | grep -o 'METERING:[^|]*' | cut -d: -f2)
        iso=$(echo "$metadata_output" | grep -o 'ISO:[^|]*' | cut -d: -f2)
        photo_date_time=$(echo "$metadata_output" | grep -o 'DATETIME:[^|]*' | cut -d: -f2)
        
        # Use photo title if available and meaningful, otherwise generate from filename
        if [ -n "$photo_title" ] && [ "$photo_title" != "$camera_make" ] && [ "$photo_title" != "$camera_model" ]; then
            title="$photo_title"
            echo "   🏷️  Using photo title: $title"
        else
            title=$(generate_title "$original_filename")
            echo "   🏷️  Generated title: $title"
        fi
        
        # Use photo description/caption if available and meaningful, otherwise leave empty
        if [ -n "$photo_description" ] && [ "$photo_description" != "$camera_make" ] && [ "$photo_description" != "$camera_model" ]; then
            description="$photo_description"
            echo "   📝 Using photo description: $description"
        elif [ -n "$photo_caption" ] && [ "$photo_caption" != "$camera_make" ] && [ "$photo_caption" != "$camera_model" ]; then
            description="$photo_caption"
            echo "   📝 Using photo caption: $description"
        else
            description=""
            echo "   📝 No description found - leaving empty"
        fi
        
        # Use photo date if available, otherwise try filename, fallback to current date
        if [ -n "$photo_date_time" ]; then
            # Convert exiftool date format (YYYY:MM:DD HH:MM:SS) to YYYY-MM-DD
            date=$(echo "$photo_date_time" | sed 's/\([0-9]\{4\}\):\([0-9]\{2\}\):\([0-9]\{2\}\).*/\1-\2-\3/')
            # Validate the extracted date
            if [[ "$date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
                echo "   📅 Using photo date: $date"
            else
                # If date parsing failed, try filename extraction
                if extracted_date=$(extract_date_from_filename "$original_filename"); then
                    date="$extracted_date"
                    echo "   📅 Using filename date: $date"
                else
                    date=$(date +%Y-%m-%d)
                    echo "   📅 Using current date: $date"
                fi
            fi
        elif extracted_date=$(extract_date_from_filename "$original_filename"); then
            date="$extracted_date"
            echo "   📅 Using filename date: $date"
        else
            date=$(date +%Y-%m-%d)
            echo "   📅 Using current date: $date"
        fi
    else
        # Fallback to basic extraction if metadata extraction fails
        title=$(generate_title "$original_filename")
        description=""
        
        if extracted_date=$(extract_date_from_filename "$original_filename"); then
            date="$extracted_date"
            echo "   📅 Using filename date: $date"
        else
            date=$(date +%Y-%m-%d)
            echo "   📅 Using current date: $date"
        fi
    fi
    
    # Create content file
    cat > "$BUNDLE_DIR/index.md" << EOF
---
title: "$title"
description: "$description"
image: "$clean_filename_output"
date: $date
draft: true
---

EOF

# Add description to post body only if it exists
if [ -n "$description" ]; then
    echo "$description" >> "$BUNDLE_DIR/index.md"
    echo "" >> "$BUNDLE_DIR/index.md"
fi
    
    # Add technical details if available
    if [ -n "$camera_make" ] || [ -n "$camera_model" ] || [ -n "$focal_length" ] || [ -n "$f_number" ] || [ -n "$exposure_time" ] || [ -n "$iso" ]; then
        cat >> "$BUNDLE_DIR/index.md" << EOF

## Technical Details

EOF
        
        # Build technical details in standard photography format: Camera | Focal Length | Aperture | Exposure | ISO
        local tech_details=""
        
        # Camera
        if [ -n "$camera_make" ] && [ -n "$camera_model" ]; then
            # Clean up redundant camera information
            local clean_make=$(echo "$camera_make" | sed 's/CORPORATION//g' | sed 's/INC//g' | sed 's/LTD//g' | sed 's/LLC//g' | sed 's/CO//g' | sed 's/\.//g' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
            local clean_model=$(echo "$camera_model" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
            
            # Check if model already contains the cleaned make
            if [[ "$clean_model" == *"$clean_make"* ]]; then
                # If model contains make, use only the model
                tech_details="$clean_model"
            elif [ -n "$clean_make" ] && [ "$clean_make" != "$clean_model" ] && [ ${#clean_make} -gt 2 ]; then
                # Use both if they're genuinely different and make is substantial (more than 2 chars)
                tech_details="$clean_make $clean_model"
            else
                # Fallback to just the model
                tech_details="$clean_model"
            fi
        elif [ -n "$camera_make" ]; then
            # Clean up make if it's the only camera info
            tech_details=$(echo "$camera_make" | sed 's/CORPORATION//g' | sed 's/INC//g' | sed 's/LTD//g' | sed 's/LLC//g' | sed 's/CO//g' | sed 's/\.//g' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        elif [ -n "$camera_model" ]; then
            tech_details="$camera_model"
        fi
        
        # Focal Length
        if [ -n "$focal_length" ] && [ "$focal_length" != "0" ] && [ "$focal_length" != "0.005714285714" ]; then
            if [ -n "$tech_details" ]; then
                tech_details="$tech_details | $focal_length mm"
            else
                tech_details="$focal_length mm"
            fi
        fi
        
        # Aperture
        if [ -n "$f_number" ] && [ "$f_number" != "0" ] && [ "$f_number" != "0.005714285714" ]; then
            if [ -n "$tech_details" ]; then
                tech_details="$tech_details | f/$f_number"
            else
                tech_details="f/$f_number"
            fi
        fi
        
        # Exposure
        if [ -n "$exposure_time" ] && [ "$exposure_time" != "0" ] && [ "$exposure_time" != "0.005714285714" ]; then
            local exposure_formatted=""
            if [[ "$exposure_time" =~ ^[0-9]+/[0-9]+$ ]]; then
                exposure_formatted="$exposure_time"
            elif [[ "$exposure_time" =~ ^[0-9]+\.?[0-9]*$ ]]; then
                # Convert decimal to fraction (e.g., 0.01666666667 -> 1/60)
                local exposure_fraction=$(awk "BEGIN {printf \"1/%.0f\", 1/$exposure_time}")
                # Handle very long exposures (over 1 second)
                if (( $(echo "$exposure_time >= 1" | bc -l 2>/dev/null || echo "0") )); then
                    exposure_formatted="${exposure_time}s"
                else
                    exposure_formatted="$exposure_fraction"
                fi
            else
                exposure_formatted="$exposure_time"
            fi
            
            if [ -n "$tech_details" ]; then
                tech_details="$tech_details | $exposure_formatted"
            else
                tech_details="$exposure_formatted"
            fi
        fi
        
        # ISO
        if [ -n "$iso" ] && [ "$iso" != "0" ] && [ "$iso" != "0.005714285714" ]; then
            if [ -n "$tech_details" ]; then
                tech_details="$tech_details | ISO $iso"
            else
                tech_details="ISO $iso"
            fi
        fi
        
        # Output the combined technical details
        if [ -n "$tech_details" ]; then
            echo "$tech_details" >> "$BUNDLE_DIR/index.md"
        fi
    fi
    
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
