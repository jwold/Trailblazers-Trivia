# GitHub Pages Deployment Guide

## What Changed

Your Trailblazers Trivia app is now a **static site** that runs entirely in the browser:

### Before (Server-based):
- Required Node.js server running 24/7
- SQLite database with 3,259 questions
- API calls for game management
- Real-time multiplayer synchronization

### After (Static site):
- No server required - runs in browser
- Questions stored in JSON files (3,259 questions preserved)
- LocalStorage for game state
- Single-device gameplay (perfect for projector/presentation)

## Deploy to GitHub Pages

### Step 1: Push to GitHub
```bash
git add -A
git commit -m "Convert to static site for GitHub Pages"
git push origin main
```

### Step 2: Enable GitHub Pages
1. Go to your repository on GitHub
2. Click **Settings** → **Pages** (in left sidebar)
3. Under "Source", select **GitHub Actions**
4. Click **Save**

### Step 3: Wait for Deployment
- GitHub will automatically build and deploy your site
- Check the **Actions** tab to see build progress
- Your site will be available at: `https://[your-username].github.io/Trailblazers-Trivia/`

## Test Locally

```bash
npm run build:gh-pages
npm run preview:static
```

Visit http://localhost:4173 to test

## Features in Static Mode

### ✅ What Works:
- All 3,259 questions across 5 categories
- Team management and scoring
- Dark mode
- Question difficulty selection
- Game progress saved in browser

### ❌ What Doesn't:
- Real multiplayer (each device has its own game)
- Admin panel editing (questions are in JSON files)
- Game codes (not needed anymore)
- Cross-device synchronization

## Editing Questions

Questions are stored in `client/public/data/`:
- `bible-easy.json` (208 questions)
- `bible-hard.json` (258 questions)
- `animals-easy.json` (479 questions)
- `animals-hard.json` (502 questions)
- etc...

To edit: modify the JSON files and commit changes.

## Custom Domain (Optional)

1. Create a file `client/public/CNAME` with your domain
2. Update DNS records to point to GitHub Pages
3. Enable HTTPS in GitHub Pages settings

## Rollback to Server Version

If you need the server version back:
```bash
git checkout main~1  # Go back one commit
PORT=8000 npm run dev
```

## Troubleshooting

- **404 errors**: Check that `base: '/Trailblazers-Trivia/'` matches your repo name
- **Blank page**: Open browser console for errors
- **Questions not loading**: Ensure JSON files are in `client/public/data/`

Your app is now ready for free, permanent hosting on GitHub Pages!