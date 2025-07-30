import { defineConfig } from "drizzle-kit";

// Default to PostgreSQL - for local SQLite development, use drizzle.config.dev.ts
if (!process.env.DATABASE_URL) {
  throw new Error("DATABASE_URL must be set");
}

export default defineConfig({
  out: "./migrations",
  schema: "./shared/schema.ts",
  dialect: "postgresql",
  dbCredentials: {
    url: process.env.DATABASE_URL,
  },
});
