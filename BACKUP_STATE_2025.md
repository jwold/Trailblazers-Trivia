# Trailblazers Trivia - Project State Backup
**Date**: January 6, 2025
**Working Server URL**: http://localhost:8000

## Current State Summary

### What's Working
- ✅ Full game functionality (Bible trivia category)
- ✅ SQLite database with questions
- ✅ Dark mode with proper contrast (WCAG AA compliant)
- ✅ Localhost-only editing feature
- ✅ Team management and scoring
- ✅ Question difficulty selection (Easy/Hard)
- ✅ Game history tracking

### Recent Changes Made

#### 1. Dark Mode Implementation
- Added complete theme context with system preference detection
- Fixed all contrast issues for accessibility
- Key files modified:
  - `/client/src/contexts/theme-context.tsx` - Theme provider
  - `/client/src/components/theme-toggle.tsx` - Toggle button (currently commented out)
  - Updated all components with dark mode classes

#### 2. Localhost-Only Editing
- Edit buttons only appear when running locally
- Uses `/client/src/lib/environment.ts` for detection
- Prevents accidental edits in production

#### 3. Bug Fixes
- Fixed JSX syntax errors (extra ">" characters in multiple files)
- Fixed schema import issues (PostgreSQL vs SQLite)
- Server configured to use SQLite for both dev and production

### Database Configuration
- **Current**: SQLite with over 1000 questions
- **Schema**: Using `@shared/sqlite-schema`
- **Location**: `/trivia.db`
- **Important**: `server/db.ts` hardcoded to use SQLite (line 31: `const isProduction = false;`)

### Server Configuration
- **Port**: Must use PORT=8000 (port 5000 blocked by macOS AirPlay)
- **Start Command**: `PORT=8000 npm run dev`
- **Binding**: `0.0.0.0` for production compatibility

### Known Issues
1. **Port 5000 Conflict**: macOS Control Center uses this port
2. **Browser Warnings**: Old browserslist data (non-critical)
3. **Theme Toggle**: Commented out due to hydration errors

## Deployment Considerations

### Current Architecture
- Express.js backend with REST API
- React + Vite frontend
- SQLite database
- Drizzle ORM
- Real-time game state polling

### Deployment Options Evaluated
1. **Railway** - Original attempt, had PostgreSQL/SQLite conflicts
2. **Fly.io** - Best for SQLite, always-on free tier
3. **Render** - Simple but has cold starts
4. **Replit** - Easy but expensive
5. **Static Site** - Would lose multiplayer features

### Environment Variables Needed
```
NODE_ENV=production
PORT=8000 (or platform default)
DATABASE_URL (if using PostgreSQL)
```

## How to Restore

1. **Start Development Server**:
   ```bash
   cd "/Users/joshuawold/Claude Projects/Trailblazers-Trivia"
   PORT=8000 npm run dev
   ```

2. **Access Application**:
   - Development: http://localhost:8000
   - Admin Panel: http://localhost:8000/admin

3. **If Port Issues**:
   ```bash
   # Kill process on port 5000
   lsof -ti:5000 | xargs kill -9
   # Or use port 8000
   PORT=8000 npm run dev
   ```

## Critical Files
- `/server/db.ts` - Database configuration
- `/server/index.ts` - Server setup and port binding
- `/client/src/contexts/theme-context.tsx` - Theme system
- `/client/src/lib/environment.ts` - Environment detection
- `/shared/sqlite-schema.ts` - Database schema

## Features Not to Lose
1. Localhost-only editing protection
2. Dark mode with proper contrast
3. SQLite database (don't accidentally switch to PostgreSQL)
4. Game state polling for multiplayer
5. Question difficulty system

## Next Steps Planned
- Deploy to production (evaluating platforms)
- Fix theme toggle hydration issue
- Consider adding more trivia categories
- Optimize for classroom use

---
This backup created after successfully implementing dark mode and fixing accessibility issues.
All systems functional as of this backup.