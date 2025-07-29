import * as schema from "@shared/schema";

// Use SQLite for local development, PostgreSQL for production
const isProduction = process.env.NODE_ENV === 'production' || process.env.DATABASE_URL;

async function createDB() {
  if (isProduction) {
    // Production: PostgreSQL
    const { Pool, neonConfig } = await import('@neondatabase/serverless');
    const { drizzle } = await import('drizzle-orm/neon-serverless');
    const ws = await import('ws');

    neonConfig.webSocketConstructor = ws.default;

    if (!process.env.DATABASE_URL) {
      throw new Error("DATABASE_URL must be set for production");
    }

    const pool = new Pool({ connectionString: process.env.DATABASE_URL });
    return drizzle({ client: pool, schema });
  } else {
    // Development: SQLite
    try {
      const Database = (await import('better-sqlite3')).default;
      const { drizzle } = await import('drizzle-orm/better-sqlite3');
      
      const sqlite = new Database('./trivia.db');
      return drizzle({ client: sqlite, schema });
    } catch (error) {
      throw new Error('SQLite dependencies not found. Run: npm install --include=dev');
    }
  }
}

export const db = await createDB();