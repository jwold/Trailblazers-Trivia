import { Pool, neonConfig } from '@neondatabase/serverless';
import { drizzle as drizzleNeon } from 'drizzle-orm/neon-serverless';
import ws from "ws";
import * as schema from "@shared/schema";

// Use SQLite for local development, PostgreSQL for production
const isProduction = process.env.NODE_ENV === 'production' || process.env.DATABASE_URL;

async function createDB() {
  if (isProduction) {
    // Production: PostgreSQL
    neonConfig.webSocketConstructor = ws;

    if (!process.env.DATABASE_URL) {
      throw new Error("DATABASE_URL must be set for production");
    }

    const pool = new Pool({ connectionString: process.env.DATABASE_URL });
    return drizzleNeon({ client: pool, schema });
  } else {
    // Development: SQLite (dynamic import to avoid production dependencies)
    const Database = (await import('better-sqlite3')).default;
    const { drizzle: drizzleSQLite } = await import('drizzle-orm/better-sqlite3');
    
    const sqlite = new Database('./trivia.db');
    return drizzleSQLite({ client: sqlite, schema });
  }
}

export const db = await createDB();