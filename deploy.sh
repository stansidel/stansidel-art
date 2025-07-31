#!/bin/bash

# Build the Hugo site
echo "Building Hugo site..."
hugo --minify

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Site built successfully!"
    echo "📁 Static files are in the 'public/' directory"
    echo "🌐 Ready for deployment to https://art.stan.sidel.family/"
    echo ""
    echo "To deploy:"
    echo "1. Upload the contents of 'public/' to your web server"
    echo "2. Ensure your domain points to the uploaded files"
else
    echo "❌ Build failed. Please check for errors above."
    exit 1
fi 