import Database from 'better-sqlite3';
import { drizzle as drizzleSQLite } from 'drizzle-orm/better-sqlite3';
import { Pool, neonConfig } from '@neondatabase/serverless';
import { drizzle as drizzleNeon } from 'drizzle-orm/neon-serverless';
import ws from "ws";
import * as schema from "@shared/schema";

// Use SQLite for local development, PostgreSQL for production
const isProduction = process.env.NODE_ENV === 'production' || process.env.DATABASE_URL;

let db: any;

if (isProduction) {
  // Production: PostgreSQL
  neonConfig.webSocketConstructor = ws;

  if (!process.env.DATABASE_URL) {
    throw new Error("DATABASE_URL must be set for production");
  }

  const pool = new Pool({ connectionString: process.env.DATABASE_URL });
  db = drizzleNeon({ client: pool, schema });
} else {
  // Development: SQLite  
  const sqlite = new Database('./trivia.db');
  db = drizzleSQLite({ client: sqlite, schema });
}

export { db };