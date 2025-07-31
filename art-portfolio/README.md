# Stan Sidel - Art Portfolio

A Hugo-based portfolio website for photography and digital art, similar to Kim Öhrling's site design.

## Features

- Clean, minimal design inspired by Kim Öhrling's portfolio
- Two main sections: Photography and Digital Art
- Image-only grid layout for category pages
- Detailed project pages with multiple images and text
- Responsive design that adapts to all screen sizes
- Custom Hugo theme

## Structure

```
art-portfolio/
├── content/
│   ├── _index.md              # Homepage
│   ├── photography/
│   │   ├── _index.md          # Photography section
│   │   ├── street-photography.md
│   │   └── landscape-photography.md
│   └── digital-art/
│       ├── _index.md          # Digital Art section
│       ├── abstract-art.md
│       └── digital-illustrations.md
├── themes/art-portfolio-theme/ # Custom theme
└── config.toml                # Hugo configuration
```

## Getting Started

1. **Install Hugo** (if not already installed):
   ```bash
   brew install hugo
   ```

2. **Run the development server**:
   ```bash
   hugo server
   ```

3. **Build for production**:
   ```bash
   hugo
   ```

## Adding New Portfolio Items

### Photography Items
Create new files in `content/photography/` with the following front matter:

```markdown
---
title: "Your Photo Title"
description: "Brief description of the photo"
image: "/images/your-photo.jpg"
additional_images: ["/images/your-photo-2.jpg", "/images/your-photo-3.jpg"]
date: 2024-01-01
---

Your content here...
```

### Digital Art Items
Create new files in `content/digital-art/` with the same front matter structure.

### Project Structure
- **Category Pages**: Show only images in a responsive grid
- **Project Pages**: Display main image, additional gallery images, and descriptive text
- **Navigation**: Clean back links to return to category pages

## Customization

### Colors and Styling
Edit `themes/art-portfolio-theme/static/css/style.css` to customize:
- Colors
- Typography
- Layout spacing
- Responsive breakpoints

### Site Configuration
Edit `config.toml` to change:
- Site title and description
- Base URL
- Menu items
- Site parameters

### Theme Templates
Modify templates in `themes/art-portfolio-theme/layouts/` to change:
- Page layouts
- Navigation structure
- Content display

## Deployment

The site is configured for deployment at `https://art.stan.sidel.family/`.

To deploy:
1. Build the site: `hugo`
2. Upload the contents of the `public/` directory to your web server

## License

This project is for personal use by Stan Sidel. 