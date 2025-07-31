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
│   ├── photography/           # Photography section
│   │   ├── _index.md
│   │   ├── street-photography/    # Page Bundle
│   │   │   ├── index.md
│   │   │   ├── street-photography.svg
│   │   │   ├── street-photography-2.svg
│   │   │   └── street-photography-3.svg
│   │   ├── landscape-photography/  # Page Bundle
│   │   │   ├── index.md
│   │   │   └── landscape-photography.svg
│   │   └── portrait-photography/   # Page Bundle
│   │       ├── index.md
│   │       └── portrait-photography.svg
│   └── digital-art/           # Digital Art section
│       ├── _index.md
│       ├── abstract-art/          # Page Bundle
│       │   ├── index.md
│       │   ├── abstract-art.svg
│       │   ├── abstract-art-2.svg
│       │   └── abstract-art-3.svg
│       ├── digital-illustrations/ # Page Bundle
│       │   ├── index.md
│       │   └── digital-illustrations.svg
│       └── digital-paintings/     # Page Bundle
│           ├── index.md
│           └── digital-paintings.svg
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
Create Page Bundles in `content/photography/` with the following structure:

```
content/photography/your-project/
├── index.md
├── your-project.jpg
├── your-project-2.jpg
└── your-project-3.jpg
```

Front matter in `index.md`:
```markdown
---
title: "Your Photo Title"
description: "Brief description of the photo"
image: "your-project.jpg"
additional_images: ["your-project-2.jpg", "your-project-3.jpg"]
date: 2024-01-01
---

Your content here...
```

### Digital Art Items
Create Page Bundles in `content/digital-art/` with the same structure.

### Using the Helper Script
```bash
./add-image.sh photography my-project "My Project Title" "Project description"
```
This creates the Page Bundle structure automatically.

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