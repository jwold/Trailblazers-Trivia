import { pgTable, text, serial, integer, boolean, varchar, timestamp } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod";

export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  username: text("username").notNull().unique(),
  password: text("password").notNull(),
});

export const triviaQuestions = pgTable("trivia_questions", {
  id: serial("id").primaryKey(),
  difficulty: varchar("difficulty", { length: 10 }).notNull(),
  question: text("question").notNull(),
  answer: text("answer").notNull(),
  reference: text("reference").notNull(),
});

export const gameSession = pgTable("game_sessions", {
  id: serial("id").primaryKey(),
  gameCode: varchar("game_code", { length: 6 }).notNull().unique(),
  teams: text("teams").notNull(), // JSON string
  currentTeamIndex: integer("current_team_index").default(0),
  targetScore: integer("target_score").default(10),

  questionHistory: text("question_history").default("[]"), // JSON string of used question IDs
  detailedHistory: text("detailed_history").default("[]"), // JSON string of detailed question history
  gamePhase: varchar("game_phase", { length: 20 }).default("setup"), // setup, playing, victory
  isActive: boolean("is_active").default(true),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});

export const insertUserSchema = createInsertSchema(users).pick({
  username: true,
  password: true,
});

export const insertTriviaQuestionSchema = createInsertSchema(triviaQuestions);

export const insertGameSessionSchema = createInsertSchema(gameSession).omit({
  id: true,
  createdAt: true,
});

export const teamSchema = z.object({
  id: z.string(),
  name: z.string().min(1, "Team name is required"),
  color: z.string(),
  score: z.number().default(0),
  correctAnswers: z.number().default(0),
});

export const questionHistoryEntrySchema = z.object({
  questionId: z.number(),
  teamId: z.string(),
  teamName: z.string(),
  difficulty: z.string(),
  question: z.string(),
  answer: z.string(),
  reference: z.string(),
  points: z.number(),
  wasCorrect: z.boolean(),
  timestamp: z.number(),
});

export const gameSetupSchema = z.object({
  teams: z.array(teamSchema).min(2, "At least 2 teams required"),
  targetScore: z.number().min(5).max(50).default(10),
});

export type User = typeof users.$inferSelect;
export type InsertUser = z.infer<typeof insertUserSchema>;
export type TriviaQuestion = typeof triviaQuestions.$inferSelect;
export type InsertTriviaQuestion = z.infer<typeof insertTriviaQuestionSchema>;
export type GameSession = typeof gameSession.$inferSelect;
export type InsertGameSession = z.infer<typeof insertGameSessionSchema>;
export type Team = z.infer<typeof teamSchema>;
export type GameSetup = z.infer<typeof gameSetupSchema>;
export type QuestionHistoryEntry = z.infer<typeof questionHistoryEntrySchema>;
