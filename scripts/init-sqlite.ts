import Database from 'better-sqlite3';

const sqlite = new Database('./trivia.db');

async function initSQLiteDatabase() {
  try {
    console.log("🔄 Initializing SQLite database...");
    
    // Create tables
    console.log("📋 Creating tables...");
    
    // Users table
    sqlite.exec(`
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    `);
    
    // Trivia questions table
    sqlite.exec(`
      CREATE TABLE IF NOT EXISTS trivia_questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        difficulty TEXT NOT NULL,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        reference TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT 'bible'
      )
    `);
    
    // Game sessions table
    sqlite.exec(`
      CREATE TABLE IF NOT EXISTS game_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        game_code TEXT NOT NULL UNIQUE,
        teams TEXT NOT NULL,
        current_team_index INTEGER DEFAULT 0,
        target_score INTEGER DEFAULT 10,
        category TEXT NOT NULL DEFAULT 'bible',
        game_mode TEXT NOT NULL DEFAULT 'regular',
        question_history TEXT DEFAULT '[]',
        detailed_history TEXT DEFAULT '[]',
        game_phase TEXT DEFAULT 'setup',
        is_active INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
      )
    `);
    
    console.log("✅ SQLite database initialized successfully!");
    
  } catch (error) {
    console.error("❌ Database initialization failed:", error);
    throw error;
  } finally {
    sqlite.close();
  }
}

initSQLiteDatabase();