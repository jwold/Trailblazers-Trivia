// Import the correct schema based on environment
const isUsingPostgres = process.env.NODE_ENV === 'production' || process.env.DATABASE_URL;
const schema = isUsingPostgres 
  ? await import("@shared/schema")
  : await import("@shared/sqlite-schema");

// Use SQLite for local development, PostgreSQL for production
const isProduction = process.env.NODE_ENV === 'production' || process.env.DATABASE_URL;

async function createDB() {
  console.log(`🔄 Initializing database (production: ${isProduction})...`);
  
  try {
    if (isProduction) {
      // Production: PostgreSQL
      console.log('📡 Connecting to PostgreSQL...');
      const { Pool, neonConfig } = await import('@neondatabase/serverless');
      const { drizzle } = await import('drizzle-orm/neon-serverless');
      const ws = await import('ws');

      neonConfig.webSocketConstructor = ws.default;

      if (!process.env.DATABASE_URL) {
        throw new Error("DATABASE_URL must be set for production");
      }

      const pool = new Pool({ connectionString: process.env.DATABASE_URL });
      const db = drizzle({ client: pool, schema });
      console.log('✅ PostgreSQL connection established');
      return db;
    } else {
      // Development: SQLite
      console.log('📁 Connecting to SQLite...');
      try {
        const Database = (await import('better-sqlite3')).default;
        const { drizzle } = await import('drizzle-orm/better-sqlite3');
        
        const sqlite = new Database('./trivia.db');
        const db = drizzle({ client: sqlite, schema });
        console.log('✅ SQLite connection established');
        return db;
      } catch (error) {
        throw new Error('SQLite dependencies not found. Run: npm install better-sqlite3');
      }
    }
  } catch (error) {
    console.error('❌ Database initialization failed:', error);
    throw error;
  }
}

export const db = await createDB();