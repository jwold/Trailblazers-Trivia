import { defineConfig } from "drizzle-kit";

const isProduction = process.env.NODE_ENV === 'production' || process.env.DATABASE_URL;

if (isProduction) {
  if (!process.env.DATABASE_URL) {
    throw new Error("DATABASE_URL must be set for production");
  }

  export default defineConfig({
    out: "./migrations",
    schema: "./shared/schema.ts",
    dialect: "postgresql",
    dbCredentials: {
      url: process.env.DATABASE_URL,
    },
  });
} else {
  export default defineConfig({
    out: "./migrations",
    schema: "./shared/schema.ts",
    dialect: "sqlite",
    dbCredentials: {
      url: "./trivia.db",
    },
  });
}
