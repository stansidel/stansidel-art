# Contact Form Setup Guide

Your contact form is now styled correctly, but it needs a form handler to actually send emails. Here are the best options:

## Option 1: Formspree (Recommended - Free & Easy)

1. **Go to [Formspree](https://formspree.io/)**
2. **Sign up for a free account**
3. **Create a new form**
4. **Copy your form ID** (it will look like `xrgjqkqj`)
5. **Replace the placeholder in the template:**

```bash
# Edit this file:
nano themes/art-portfolio-theme/layouts/_default/contact.html
```

Find this line:
```html
<form class="contact-form" action="https://formspree.io/f/YOUR_FORM_ID" method="POST">
```

Replace `YOUR_FORM_ID` with your actual form ID:
```html
<form class="contact-form" action="https://formspree.io/f/xrgjqkqj" method="POST">
```

## Option 2: Netlify Forms (If hosting on Netlify)

Add `data-netlify="true"` to the form tag:

```html
<form class="contact-form" action="https://formspree.io/f/YOUR_FORM_ID" method="POST" data-netlify="true">
```

## Option 3: EmailJS (Advanced)

For more control, you can use EmailJS to send emails directly from the browser.

## Testing the Form

Once you've set up a form handler:

1. **Fill out the form** on your contact page
2. **Submit it** - you should receive a confirmation
3. **Check your email** - you should receive the form submission

## Current Status

✅ **Form styling is working** - the form looks professional  
✅ **Form structure is correct** - all fields are properly rendered  
❌ **Form submission needs setup** - you need to choose a form handler

The form is ready to use once you set up a form handler! 