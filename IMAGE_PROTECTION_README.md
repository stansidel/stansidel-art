# Image Protection System

This Hugo theme includes a comprehensive image protection system designed to prevent unauthorized downloading of high-resolution images while maintaining good user experience for web viewing.

## How It Works

### 1. **Resolution Limiting**
- **Main images**: Automatically resized to maximum 800px width with 75% quality
- **Gallery images**: Automatically resized to maximum 600x600px with 70% quality
- **SVG images**: Served at full resolution (vector graphics are safe to share)

### 2. **Modal Protection** ⚠️ **DISABLED**
- **Modal functionality has been commented out** for maximum protection
- Users can no longer click images to view larger versions
- Images are displayed at reduced resolution only
- No watermark overlay or protection notices shown

### 3. **Download Prevention**
- **Right-click context menu disabled** on all images
- **Drag-and-drop prevented** globally
- **Image selection disabled** globally
- All images marked as **non-selectable**
- **No clickable interactions** - images are static

### 4. **User Experience**
- Images display at web-optimized resolution only
- No visual indicators for clicking or zooming
- Clean, professional appearance
- Maximum protection level achieved

## Re-enabling Modal Functionality

If you want to allow users to view larger images again in the future, you can re-enable the modal by:

### 1. **Uncomment the Template Code**
In `themes/art-portfolio-theme/layouts/_default/single.html`:
- Remove the `<!--` and `-->` comment markers around the modal HTML
- Change `class="protected-image"` back to `class="clickable-image"`
- Uncomment the image overlay divs
- Uncomment the JavaScript code

### 2. **Uncomment the CSS**
In `themes/art-portfolio-theme/static/css/style.css`:
- Remove the `/*` and `*/` comment markers around the modal styles
- The watermark overlay and protection notice styles will become active again

### 3. **Restore Clickable Behavior**
- Images will become clickable again
- Modal will open with watermarked versions
- Protection notices will be displayed

## Current Protection Level: MAXIMUM

With the modal disabled, your images now have the highest level of protection:
- ✅ **No enlarged viewing possible**
- ✅ **No watermark overlay needed**
- ✅ **No clickable interactions**
- ✅ **Maximum deterrent against casual downloading**
- ✅ **Clean, professional appearance**

## Configuration

The image protection settings are still centralized in `themes/art-portfolio-theme/layouts/partials/image-protection-config.html` and can be adjusted for resolution and quality even with the modal disabled.
