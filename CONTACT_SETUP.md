# Contact Form Setup

I've created a contact form similar to Peter McKinnon's style for your art portfolio. Here's how to set it up:

## 1. Add Your Contact Photo

### Option A: Simple Static Photo (Current Setup)
Use the provided script to add your photo:

```bash
./add-contact-photo.sh /path/to/your/photo.jpg
```

This will copy your photo to `static/contact-photo.jpg` and it will be served directly.

### Option B: Optimized Photo with Build-time Processing
For automatic image optimization:

1. **Copy your photo to assets directory:**
   ```bash
   cp /path/to/your/photo.jpg assets/contact-photo.jpg
   ```

2. **Update the contact page to use the optimized template:**
   ```bash
   # Edit content/contact.md and change the layout:
   layout: "contact-optimized"
   ```

This will automatically resize your photo to 800x1200 with WebP optimization during build.

## 2. Set Up Form Handling

For a static website, you have several options for handling form submissions:

### Option A: Formspree (Recommended)
1. Go to [Formspree](https://formspree.io/) and create a free account
2. Create a new form
3. Copy your form ID (it will look like `xrgjqkqj`)
4. Replace `YOUR_FORM_ID` in the template with your actual form ID

### Option B: Netlify Forms
If you're hosting on Netlify, add `data-netlify="true"` to the form tag.

### Option C: EmailJS
For more control, you can use EmailJS to send emails directly from the browser.

## 3. Customize Contact Information

Edit the contact information in the template files:
- Update the email address
- Change the location
- Modify the description text

## 4. Test the Form

1. Run your Hugo site locally: `hugo server`
2. Navigate to `/contact/`
3. Test the form submission

## Features

- ✅ Responsive design that works on mobile and desktop
- ✅ Clean, professional styling similar to Peter McKinnon's site
- ✅ Form validation (required fields, minimum message length)
- ✅ Contact photo display with size optimization
- ✅ Contact information section
- ✅ Navigation menu integration
- ✅ Two image processing options (static vs optimized)

## Image Processing Options

**Current Setup (Static):**
- Photo served directly from `static/contact-photo.jpg`
- No build-time processing
- Faster build times
- Larger file sizes

**Optimized Setup (Assets):**
- Photo processed during build
- Automatic resizing to 800x1200
- WebP format with 85% quality
- Smaller file sizes, better performance
- Requires `layout: "contact-optimized"`

The contact page is now accessible at `/contact/` and appears in your navigation menu. 