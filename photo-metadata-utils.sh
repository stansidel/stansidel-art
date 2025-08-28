#!/bin/bash

# Shared utility functions for photo metadata extraction
# This script can be sourced by other scripts to avoid code duplication

# Function to extract photo metadata using exiftool
extract_photo_metadata() {
    local image_file="$1"
    
    # Check if exiftool is available
    if ! command -v exiftool &> /dev/null; then
        echo "⚠️  exiftool not found - metadata extraction disabled" >&2
        return 1
    fi
    
    # Extract metadata fields individually
    local title=$(exiftool -Title -b "$image_file" 2>/dev/null)
    local description=$(exiftool -Description -b "$image_file" 2>/dev/null)
    local caption=$(exiftool -Caption-Abstract -b "$image_file" 2>/dev/null)
    local make=$(exiftool -Make -b "$image_file" 2>/dev/null)
    
    # Try to get camera model from multiple possible fields
    local model=$(exiftool -"Camera Model Name" -b "$image_file" 2>/dev/null)
    if [ -z "$model" ]; then
        model=$(exiftool -Model -b "$image_file" 2>/dev/null)
    fi
    if [ -z "$model" ]; then
        model=$(exiftool -"Model Name" -b "$image_file" 2>/dev/null)
    fi
    
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
    echo "$title"
}

# Function to extract date from filename
extract_date_from_filename() {
    local filename="$1"
    local basename=$(basename "$filename" | sed 's/\.[^.]*$//')
    
    # Try to match YYYYMMDD format (8 digits at the beginning)
    if [[ "$basename" =~ ^([0-9]{8}) ]]; then
        local date_str="${BASH_REMATCH[1]}"
        local year="${date_str:0:4}"
        local month="${date_str:2:2}"
        local day="${date_str:4:2}"
        
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

# Function to format technical details for output
format_technical_details() {
    local camera_make="$1"
    local camera_model="$2"
    local focal_length="$3"
    local f_number="$4"
    local exposure_time="$5"
    local iso="$6"
    
    local tech_details=""
    
    # Camera
    if [ -n "$camera_make" ] && [ -n "$camera_model" ]; then
        # Clean up redundant camera information more carefully
        clean_make=$(echo "$camera_make" | sed 's/CORPORATION//g' | sed 's/INC//g' | sed 's/LTD//g' | sed 's/LLC//g' | sed 's/CO//g' | sed 's/\.//g' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        clean_model=$(echo "$camera_model" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        
        # Check if model already contains the cleaned make (case-insensitive)
        if [[ "$(echo "$clean_model" | tr '[:upper:]' '[:lower:]')" == *"$(echo "$clean_make" | tr '[:upper:]' '[:lower:]')"* ]]; then
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
        # Clean up make if it's the only camera info, but preserve case
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
            tech_details="$tech_details | f/$f_number"
        fi
    fi
    
    # Exposure
    if [ -n "$exposure_time" ] && [ "$exposure_time" != "0" ]; then
        exposure_formatted=""
        if [[ "$exposure_time" =~ ^[0-9]+/[0-9]+$ ]]; then
            exposure_formatted="$exposure_time"
        elif [[ "$exposure_time" =~ ^[0-9]+\.?[0-9]*$ ]]; then
            # Convert decimal to fraction (e.g., 0.01666666667 -> 1/60)
            exposure_fraction=$(awk "BEGIN {printf \"1/%.0f\", 1/$exposure_time}")
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
    
    echo "$tech_details"
}



# Function to generate Hugo frontmatter and content
generate_hugo_content() {
    local title="$1"
    local description="$2"
    local image_filename="$3"
    local date="$4"
    local camera_make="$5"
    local camera_model="$6"
    local focal_length="$7"
    local f_number="$8"
    local exposure_time="$9"
    local iso="${10}"
    
    # Create the frontmatter
    cat << EOF
---
title: "$title"
description: "$description"
image: "$image_filename"
date: $date
draft: true
---

EOF
    
    # Add description to post body only if it exists
    if [ -n "$description" ]; then
        echo "$description"
        echo ""
    fi
    
    # Add technical details if available
    if [ -n "$camera_make" ] || [ -n "$camera_model" ] || [ -n "$focal_length" ] || [ -n "$f_number" ] || [ -n "$exposure_time" ] || [ -n "$iso" ]; then
        echo ""
        
        # Use the shared function to format technical details
        tech_details=$(format_technical_details "$camera_make" "$camera_model" "$focal_length" "$f_number" "$exposure_time" "$iso")
        
        # Output the combined technical details
        if [ -n "$tech_details" ]; then
            echo "$tech_details"
        fi
    fi
}

# Function to parse content output string into individual variables
parse_content_output() {
    local content_output="$1"
    
    # Parse the returned content string (key:value|key:value format)
    local title=$(echo "$content_output" | grep -o 'TITLE:[^|]*' | cut -d: -f2)
    local description=$(echo "$content_output" | grep -o 'DESCRIPTION:[^|]*' | cut -d: -f2)
    local date=$(echo "$content_output" | grep -o 'DATE:[^|]*' | cut -d: -f2)
    local camera_make=$(echo "$content_output" | grep -o 'MAKE:[^|]*' | cut -d: -f2)
    local camera_model=$(echo "$content_output" | grep -o 'MODEL:[^|]*' | cut -d: -f2)
    local focal_length=$(echo "$content_output" | grep -o 'FOCAL:[^|]*' | cut -d: -f2)
    local f_number=$(echo "$content_output" | grep -o 'FNUMBER:[^|]*' | cut -d: -f2)
    local exposure_time=$(echo "$content_output" | grep -o 'EXPOSURE:[^|]*' | cut -d: -f2)
    local iso=$(echo "$content_output" | grep -o 'ISO:[^|]*' | cut -d: -f2)
    
    # Return all values as a structured string
    echo "TITLE:$title|DESCRIPTION:$description|DATE:$date|MAKE:$camera_make|MODEL:$camera_model|FOCAL:$focal_length|FNUMBER:$f_number|EXPOSURE:$exposure_time|ISO:$iso"
}
