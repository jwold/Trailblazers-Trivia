import { users, triviaQuestions, gameSession, type User, type InsertUser, type TriviaQuestion, type InsertTriviaQuestion, type GameSession, type InsertGameSession, type Team } from "@shared/schema";
import { db } from "./db";
import { eq, and } from "drizzle-orm";

export interface IStorage {
  getUser(id: number): Promise<User | undefined>;
  getUserByUsername(username: string): Promise<User | undefined>;
  createUser(user: InsertUser): Promise<User>;
  
  // Trivia Questions
  getAllQuestions(): Promise<TriviaQuestion[]>;
  getQuestionsByDifficulty(difficulty: string): Promise<TriviaQuestion[]>;
  getQuestionsByDifficultyAndCategory(difficulty: string, category: string): Promise<TriviaQuestion[]>;
  getRandomQuestion(difficulty: string, excludeIds: number[], category?: string): Promise<TriviaQuestion | undefined>;
  
  // Game Sessions
  createGameSession(session: InsertGameSession): Promise<GameSession>;
  getGameSession(gameCode: string): Promise<GameSession | undefined>;
  updateGameSession(gameCode: string, updates: Partial<GameSession>): Promise<GameSession | undefined>;
  deleteGameSession(gameCode: string): Promise<boolean>;
}

export class DatabaseStorage implements IStorage {
  async getUser(id: number): Promise<User | undefined> {
    const [user] = await db.select().from(users).where(eq(users.id, id));
    return user || undefined;
  }

  async getUserByUsername(username: string): Promise<User | undefined> {
    const [user] = await db.select().from(users).where(eq(users.username, username));
    return user || undefined;
  }

  async createUser(insertUser: InsertUser): Promise<User> {
    const [user] = await db
      .insert(users)
      .values(insertUser)
      .returning();
    return user;
  }

  async getAllQuestions(): Promise<TriviaQuestion[]> {
    return await db.select().from(triviaQuestions);
  }

  async getQuestionsByDifficulty(difficulty: string): Promise<TriviaQuestion[]> {
    return await db.select().from(triviaQuestions).where(eq(triviaQuestions.difficulty, difficulty));
  }

  async getQuestionsByDifficultyAndCategory(difficulty: string, category: string): Promise<TriviaQuestion[]> {
    return await db.select().from(triviaQuestions)
      .where(and(
        eq(triviaQuestions.difficulty, difficulty),
        eq(triviaQuestions.category, category)
      ));
  }

  async getRandomQuestion(difficulty: string, excludeIds: number[] = [], category: string = "bible"): Promise<TriviaQuestion | undefined> {
    const questions = await this.getQuestionsByDifficultyAndCategory(difficulty, category);
    const availableQuestions = questions.filter(q => !excludeIds.includes(q.id));
    
    if (availableQuestions.length === 0) return undefined;
    
    const randomIndex = Math.floor(Math.random() * availableQuestions.length);
    return availableQuestions[randomIndex];
  }

  async createGameSession(session: InsertGameSession): Promise<GameSession> {
    const [newGameSession] = await db
      .insert(gameSession)
      .values(session)
      .returning();
    return newGameSession;
  }

  async getGameSession(gameCode: string): Promise<GameSession | undefined> {
    const [session] = await db.select().from(gameSession).where(eq(gameSession.gameCode, gameCode));
    return session || undefined;
  }

  async updateGameSession(gameCode: string, updates: Partial<GameSession>): Promise<GameSession | undefined> {
    const [updatedSession] = await db
      .update(gameSession)
      .set(updates)
      .where(eq(gameSession.gameCode, gameCode))
      .returning();
    return updatedSession || undefined;
  }

  async deleteGameSession(gameCode: string): Promise<boolean> {
    const result = await db.delete(gameSession).where(eq(gameSession.gameCode, gameCode));
    return (result.rowCount ?? 0) > 0;
  }
}

export const storage = new DatabaseStorage();
