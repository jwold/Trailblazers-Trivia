# Bible Trivia Quest - Replit Configuration

## Overview

This is a full-stack Bible trivia game application designed for kids (ages 10-12). The app allows teams to compete in Bible knowledge questions across different difficulty levels with a playful, cartoonish interface. The application is built as a web-based game with no account requirements, focusing on ease of use and engagement.

## User Preferences

Preferred communication style: Simple, everyday language.

## System Architecture

### Technology Stack
The application follows a modern full-stack architecture using:
- **Frontend**: React with TypeScript, Vite for build tooling
- **Backend**: Express.js with TypeScript
- **Database**: PostgreSQL with Drizzle ORM
- **UI Framework**: Tailwind CSS with shadcn/ui components
- **State Management**: TanStack Query for server state management
- **Routing**: Wouter for client-side routing

### Architecture Pattern
The system uses a monorepo structure with clear separation between client, server, and shared code:
- `client/` - React frontend application
- `server/` - Express.js backend API
- `shared/` - Common types and schemas used by both frontend and backend

## Key Components

### Frontend Architecture
- **Component-based UI**: Uses React functional components with hooks
- **Design System**: shadcn/ui components with Tailwind CSS for consistent styling
- **Game State Management**: Local component state with TanStack Query for server synchronization
- **Responsive Design**: Mobile-friendly interface optimized for touch interactions

### Backend Architecture
- **RESTful API**: Express.js server providing game management endpoints
- **Data Storage**: In-memory storage with interface for future database integration
- **Game Session Management**: Handles game creation, state updates, and question delivery
- **Question Bank**: Curated trivia questions categorized by difficulty

### Database Schema
The application defines three main entities:
- **Users**: Basic user information (currently unused in MVP)
- **Trivia Questions**: Question bank with difficulty levels, answers, and Bible references
- **Game Sessions**: Active game state including teams, scores, and question history

## Data Flow

### Game Creation Flow
1. Users set up teams and game parameters in the frontend
2. Frontend sends game configuration to `/api/games` endpoint
3. Backend generates unique game code and creates session
4. Game code returned to frontend for game access

### Gameplay Flow
1. Teams select difficulty level
2. Frontend requests question from `/api/games/:gameCode/question/:difficulty`
3. Backend returns random question excluding previously asked ones
4. Game leader marks answers correct/incorrect
5. Scores updated and stored in game session
6. Game continues until target score reached

### Question Management
- Questions stored with difficulty categorization (Easy, Medium, Hard)
- Scoring system: Easy = 1 point, Medium = 2 points, Hard = 3 points
- Bible references provided for educational value
- Hint system available for accessibility
- Complete 500-question database loaded from CSV

## External Dependencies

### Core Dependencies
- **React Ecosystem**: React, React DOM, React Query for frontend
- **UI Components**: Radix UI primitives with shadcn/ui wrapper components
- **Database**: Drizzle ORM with PostgreSQL adapter (@neondatabase/serverless)
- **Validation**: Zod for schema validation
- **Styling**: Tailwind CSS with class-variance-authority for component variants

### Development Tools
- **Build Tools**: Vite for frontend, esbuild for backend bundling
- **Type Safety**: TypeScript throughout the application
- **Development**: tsx for TypeScript execution, hot reload support

### Notable Integrations
- **Replit-specific**: Custom plugins for development environment integration
- **Bible API**: Planned integration with bible-api.com for verse text retrieval
- **Confetti Effects**: Custom animation system for celebration feedback

## Deployment Strategy

### Build Process
- **Frontend**: Vite builds React app to `dist/public`
- **Backend**: esbuild bundles Express server to `dist/index.js`
- **Development**: Hot reload with Vite dev server proxying to Express

### Environment Configuration
- **Database**: Uses `DATABASE_URL` environment variable for PostgreSQL connection
- **Development**: NODE_ENV controls development vs production behavior
- **Replit Integration**: Special handling for Replit environment detection

### Scalability Considerations
- **Storage Interface**: Abstract storage layer allows switching from in-memory to database
- **Session Management**: Game codes provide stateless session identification  
- **Question Bank**: Designed to scale from initial 30+ questions to hundreds
- **Caching**: Client-side question caching for offline-friendly experience

The application prioritizes simplicity and user experience while maintaining a clean, extensible architecture that can grow with additional features and user load.

## Recent Changes

- **January 24, 2025**: Removed timer functionality completely from game interface and setup
- **January 24, 2025**: Updated scoring system from Easy=3pts, Medium=2pts, Hard=1pt to Easy=1pt, Medium=2pts, Hard=3pts
- **January 24, 2025**: Added PostgreSQL database with 500 curated trivia questions loaded from CSV
- **January 24, 2025**: Enhanced "Start Bible Trivia Quest" button visibility with stronger colors and shadows
- **January 24, 2025**: Simplified team setup by removing manual color selection - colors are now auto-assigned
- **January 24, 2025**: Added default team names based on colors (Blue Team, Green Team, etc.) so users can start immediately
- **January 24, 2025**: Removed all hint functionality from game interface for cleaner experience
- **January 24, 2025**: Implemented random starting team selection to make games more fair
- **January 24, 2025**: Enhanced "Next Question" button visibility with solid blue gradient, larger size, and helpful text (removed blinking animation)
- **January 24, 2025**: Made "Next Question" button always visible (disabled/grayed during question phase, prominent during answer phase)
- **January 24, 2025**: Removed reveal functionality - answers now always show below questions in smaller text for simplified gameplay
- **January 24, 2025**: Streamlined game flow by eliminating separate answer-reveal phase and reveal button
- **January 24, 2025**: Replaced fixed target score buttons (10, 15, 20) with plus/minus increment system allowing scores from 10-50 points
- **January 24, 2025**: Added back "Add Team" button to allow up to 6 teams in game setup
- **January 24, 2025**: Added delete buttons to teams beyond the first two, allowing removal of additional teams
- **January 24, 2025**: Simplified start button text from "Start Bible Trivia Quest!" to just "Start"