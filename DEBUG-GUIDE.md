# Trailblazers Trivia Static Site Debugging Guide

## Quick Debug Steps

When experiencing a blank screen on game start, follow these steps:

### 1. Open Browser Developer Tools
- Press F12 or right-click → Inspect
- Go to Console tab

### 2. Check for Console Errors
Look for any error messages, particularly:
- **404 errors** for missing data files
- **Network errors** when loading manifest.json or question files
- **JavaScript errors** that prevent React from rendering
- **Base path issues** with incorrect file paths

### 3. Use the Built-in Debug Panel
- If you see a red bug icon (🐛) in the header, click it to open the Debug Panel
- Click "Run Debug Tests" to test all major components
- Review the results for any failed tests

### 4. Use the Console Debug Script
Copy and paste this into the browser console:

```javascript
// Copy the contents of debug-static-site.js here
```

### 5. Manual Checks

#### Check Base Path Configuration
In the console, run:
```javascript
console.log('Current URL:', window.location.href);
console.log('Base path detection:', window.location.pathname.includes('/Trailblazers-Trivia/') ? '/Trailblazers-Trivia/' : '/');
```

#### Test Data Loading Manually
```javascript
// Test manifest loading
fetch('/Trailblazers-Trivia/data/manifest.json')
  .then(r => r.json())
  .then(console.log)
  .catch(console.error);

// Test question loading
fetch('/Trailblazers-Trivia/data/bible-easy.json')
  .then(r => r.json())
  .then(data => console.log('Questions loaded:', data.length))
  .catch(console.error);
```

#### Check LocalStorage
```javascript
console.log('Current Game:', localStorage.getItem('currentGame'));
console.log('Used Questions:', localStorage.getItem('usedQuestions'));
```

## Common Issues and Solutions

### Issue 1: 404 Errors for Data Files
**Symptoms:** Console shows 404 errors when trying to load manifest.json or question files
**Solutions:**
- Verify files exist in `/dist/data/` directory
- Check if server is serving files from correct base path
- Ensure server is configured to serve static files from the `dist` directory

### Issue 2: Base Path Configuration
**Symptoms:** Files load from wrong paths (e.g., `/data/` instead of `/Trailblazers-Trivia/data/`)
**Solutions:**
- The app now auto-detects base path based on current URL
- If still failing, check that Vite build is using correct base path in vite.config.gh-pages.ts

### Issue 3: Game State Not Loading
**Symptoms:** Game starts but shows loading indefinitely
**Solutions:**
- Check if game creation succeeded in localStorage
- Verify API request routing is working correctly
- Look for JavaScript errors in staticGameService

### Issue 4: React Not Rendering
**Symptoms:** Completely blank page with no errors
**Solutions:**
- Check if root element exists: `document.getElementById('root')`
- Look for JavaScript errors that prevent React from mounting
- Verify all required scripts are loading correctly

### Issue 5: CORS or Network Issues
**Symptoms:** Network tab shows failed requests
**Solutions:**
- Ensure server is running on correct port (3000)
- Check if server allows requests from your domain
- Verify file permissions on static assets

## File Structure Check

Ensure your `dist` directory has this structure:
```
dist/
├── index.html
├── assets/
│   ├── index-[hash].css
│   └── index-[hash].js
└── data/
    ├── manifest.json
    ├── bible-easy.json
    ├── bible-hard.json
    ├── animals-easy.json
    ├── animals-hard.json
    ├── geography-easy.json
    ├── geography-hard.json
    ├── us_history-easy.json
    ├── us_history-hard.json
    ├── world_history-easy.json
    └── world_history-hard.json
```

## Server Configuration

If running locally, ensure your server:
1. Serves static files from the `dist` directory
2. Has the correct base path configuration
3. Allows access to the `/Trailblazers-Trivia/` route
4. Serves JSON files with correct MIME type

## Advanced Debugging

### Enable Verbose Logging
The updated static service now includes extensive console logging. Check the console for:
- "App started, loading manifest..."
- "Loading manifest from: [URL]"
- "Manifest loaded successfully: [object]"
- "Creating game with setup: [object]"
- "Game created and saved to localStorage: [object]"

### Network Tab Analysis
1. Go to Network tab in DevTools
2. Try starting a game
3. Look for failed requests (red status codes)
4. Check response content for any error messages

### Storage Tab Analysis
1. Go to Application/Storage tab in DevTools
2. Check Local Storage for 'currentGame' and 'usedQuestions' entries
3. Verify the data looks correct

## Contact Information

If these steps don't resolve the issue, provide:
1. Console error messages (full text)
2. Network tab screenshot of failed requests
3. Current URL where the issue occurs
4. Browser and version information
5. Results from the debug panel tests