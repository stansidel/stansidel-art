# GitHub Pages Setup Guide

This guide will help you set up automatic deployment of your Hugo art portfolio to GitHub Pages.

## Prerequisites

1. Your Hugo site is already in a GitHub repository
2. You have admin access to the repository

## Setup Steps

### 1. Enable GitHub Pages

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Pages**
3. Under **Source**, select **GitHub Actions**
4. This will allow the workflow to deploy your site

### 2. Configure Repository Settings

1. In **Settings** → **Pages**:
   - **Source**: GitHub Actions
   - **Branch**: Leave as default (GitHub Actions will handle deployment)

### 3. Push Your Changes

The GitHub Actions workflow will automatically:
- Build your Hugo site
- Deploy it to GitHub Pages
- Make it available at `https://[username].github.io/[repository-name]/`

### 4. Custom Domain (Optional)

If you want to use a custom domain:

1. In **Settings** → **Pages**:
   - Add your custom domain (e.g., `art.stan.sidel.family`)
   - Check "Enforce HTTPS"
2. Update your DNS settings to point to GitHub Pages
3. Update the `baseURL` in `config.toml` to match your custom domain

## Workflow Details

The GitHub Actions workflow (`.github/workflows/deploy.yml`) will:

- Trigger on pushes to the `main` branch
- Build the Hugo site with optimizations
- Deploy to GitHub Pages automatically
- Use the extended version of Hugo for better image processing

## Local Development

For local development, use:
```bash
hugo server
```

For production builds:
```bash
hugo --minify
```

## Troubleshooting

- Check the **Actions** tab in your repository for build logs
- Ensure all Hugo dependencies are properly committed
- Verify that the `main` branch contains your latest changes

## File Structure

- `config.toml`: Main Hugo configuration
- `config.github.toml`: GitHub Pages specific configuration
- `.github/workflows/deploy.yml`: GitHub Actions workflow
- `public/`: Build output (ignored by git)

Your site will be available at: `https://[username].github.io/art.stansidel/` 