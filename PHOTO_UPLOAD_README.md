# Photo Upload Scripts for Hugo Portfolio

This directory contains several scripts to help you quickly add photos to your Hugo art portfolio website.

## Scripts Overview

### 1. `add-image.sh` - Single Photo Upload
**Usage:** `./add-image.sh <category> <image-name> <title> <description>`

Creates a single Hugo page bundle for one photo.

**Example:**
```bash
./add-image.sh photography sunset-beach "Sunset at the Beach" "A beautiful sunset over the ocean"
```

### 2. `add-multiple-photos.sh` - Bulk Photo Upload ⭐ NEW
**Usage:** `./add-multiple-photos.sh <category> <photos-directory> [title-prefix]`

Processes all photos in a directory at once, creating Hugo page bundles for each one.

**Features:**
- Automatically renames files (replaces special characters with underscores)
- Consolidates consecutive underscores into single ones
- Generates clean, URL-friendly filenames
- **Extracts dates from filenames** (supports YYYYMMDD and YYMMDD formats)
- **Extracts photo metadata** (title, description, camera settings, etc.)
- Creates Hugo page bundles with proper front matter
- Skips photos that already have bundles (safe to run multiple times)

**Examples:**
```bash
# Upload all photos from a directory
./add-multiple-photos.sh photography ~/Pictures/portfolio

# Upload with a title prefix
./add-multiple-photos.sh digital-art ~/Artwork/abstract "Abstract Art"
```

### 3. `batch-upload.sh` - Multi-Category Batch Upload ⭐ NEW
**Usage:** `./batch-upload.sh <config-file>`

Processes multiple directories and categories at once using a configuration file.

**Example:**
```bash
# Create a config file first, then run batch upload
./batch-upload.sh batch-config.txt
```

### 4. `add-contact-photo.sh` - Contact Photo Upload
**Usage:** `./add-contact-photo.sh /path/to/your/photo.jpg`

Adds a contact photo to your static directory.

## File Renaming Rules

The `add-multiple-photos.sh` script automatically cleans filenames:

- **Before:** `My Photo (2024) - Version 2.jpg`
- **After:** `My_Photo_2024_Version_2.jpg`

**Special character handling:**
- Spaces, dashes, parentheses, brackets → Underscores
- Consecutive underscores → Single underscore
- Leading/trailing underscores → Removed
- Alphanumeric characters → Preserved

**Date extraction:**
- **YYYYMMDD format:** `20241225_Sunset_Beach.jpg` → Date: 2024-12-25
- **YYMMDD format:** `241225_Sunset_Beach.jpg` → Date: 2024-12-25
- Falls back to current date if no valid date found in filename

## Requirements

- **exiftool:** Required for metadata extraction (automatically detected)
- **Bash:** Scripts require bash shell
- **File permissions:** Scripts must be executable

## Supported Image Formats

- JPG/JPEG
- PNG
- GIF
- WebP
- SVG

**Note:** Metadata extraction works best with camera photos (JPG, RAW formats). Some formats may have limited metadata.

## Quick Start Guide

### Option 1: Bulk Upload (Recommended)
```bash
# Make scripts executable
chmod +x add-multiple-photos.sh batch-upload.sh

# Upload all photos from a directory
./add-multiple-photos.sh photography ~/Pictures/portfolio

# Or use batch upload for multiple categories
./batch-upload.sh batch-config-example.txt
```

### Option 2: Single Photo Upload
```bash
chmod +x add-image.sh
./add-image.sh photography my-photo "My Photo Title" "Description"
```

## Configuration File Format

For batch uploads, create a text file with this format:
```
CATEGORY:PHOTOS_DIRECTORY:TITLE_PREFIX
```

**Example (`my-config.txt`):**
```
photography:~/Pictures/portfolio:Photography
digital-art:~/Artwork/abstract:Abstract Art
photography:~/Pictures/street:Street Photography
```

## What Gets Created

For each photo, the script creates:

1. **Directory:** `content/<category>/<clean-filename>/`
2. **Image:** Copied with cleaned filename
3. **Content file:** `index.md` with Hugo front matter
4. **Bundle structure:** Ready for Hugo page bundles

## Date Extraction

The script automatically detects dates in filenames:

- **YYYYMMDD format:** Files starting with 8 digits (e.g., `20241225_photo.jpg`)
- **YYMMDD format:** Files starting with 6 digits (e.g., `241225_photo.jpg`)
- **Validation:** Checks for valid month (01-12) and day (01-31) ranges
- **Fallback:** Uses current date if no valid date is found
- **Output:** Hugo front matter includes the extracted date for proper content organization

## Photo Metadata Extraction

The script automatically extracts rich metadata from your photos using `exiftool`:

### **Content Fields:**
- **Title:** Used as the Hugo post title (if available in photo metadata)
- **Description/Caption:** Placed in the post body
- **Date:** Extracted from photo's original capture date

### **Technical Details (added to post bottom):**
- **Camera:** Make and model
- **Focal Length:** Lens focal length
- **Aperture:** f-number
- **Exposure Time:** Shutter speed
- **ISO:** Film/sensor sensitivity
- **Metering Mode:** How the camera metered the scene

### **Metadata Priority:**
1. **Photo metadata** (from EXIF/IPTC data)
2. **Filename date** (YYYYMMDD/YYMMDD format)
3. **Generated content** (fallback options)

## Safety Features

- **No overwrites:** Scripts skip existing bundles
- **Safe to re-run:** Can be executed multiple times safely
- **Backup friendly:** Original files are never modified
- **Error handling:** Graceful failure with helpful error messages

## Troubleshooting

### Common Issues

1. **Permission denied:** Make scripts executable with `chmod +x`
2. **Category not found:** Ensure the category directory exists in `content/`
3. **No images found:** Check supported formats and file extensions
4. **Script not found:** Ensure you're in the correct directory
5. **Metadata extraction fails:** Ensure `exiftool` is installed and accessible
6. **No metadata found:** Some image formats or edited photos may have limited metadata

### Getting Help

- Check script usage with `./script-name.sh` (no arguments)
- Verify your Hugo content structure
- Ensure image files are readable

## Next Steps

After running the scripts:

1. **Review content:** Check generated `index.md` files
2. **Customize:** Edit titles, descriptions, and content
3. **Preview:** Run `hugo server` to see your site
4. **Deploy:** Use your existing deployment process

## Tips

- **Organize photos:** Group similar photos in directories before uploading
- **Use prefixes:** Title prefixes help organize content by series or theme
- **Batch process:** Use batch upload for large collections
- **Clean filenames:** Scripts handle messy filenames automatically
- **Safe re-runs:** Scripts can be run multiple times safely
