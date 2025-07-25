import type { Express } from "express";
import { createServer, type Server } from "http";
import { storage } from "./storage";
import { gameSetupSchema, type Team } from "@shared/schema";
import { z } from "zod";

export async function registerRoutes(app: Express): Promise<Server> {
  // Generate a random 6-character game code
  function generateGameCode(): string {
    return Math.random().toString(36).substring(2, 8).toUpperCase();
  }

  // Create a new game session
  app.post("/api/games", async (req, res) => {
    try {
      const gameData = gameSetupSchema.parse(req.body);
      
      const gameCode = generateGameCode();
      // Set random starting team
      const randomStartingTeam = Math.floor(Math.random() * gameData.teams.length);
      
      const session = await storage.createGameSession({
        gameCode,
        teams: JSON.stringify(gameData.teams),
        targetScore: gameData.targetScore,
        currentTeamIndex: randomStartingTeam,
        questionHistory: "[]",
        detailedHistory: "[]",
        gamePhase: "playing",
        isActive: true,
      });

      res.json({ gameCode, session });
    } catch (error) {
      console.error("Error creating game:", error);
      res.status(400).json({ message: "Invalid game data" });
    }
  });

  // Get game session
  app.get("/api/games/:gameCode", async (req, res) => {
    try {
      const { gameCode } = req.params;
      const session = await storage.getGameSession(gameCode);
      
      if (!session) {
        return res.status(404).json({ message: "Game not found" });
      }

      const teams: Team[] = JSON.parse(session.teams || "[]");
      const questionHistory: number[] = JSON.parse(session.questionHistory || "[]");
      const detailedHistory = JSON.parse(session.detailedHistory || "[]");

      res.json({
        ...session,
        teams,
        questionHistory,
        detailedHistory,
      });
    } catch (error) {
      console.error("Error fetching game:", error);
      res.status(500).json({ message: "Internal server error" });
    }
  });

  // Get a random question
  app.get("/api/games/:gameCode/question/:difficulty", async (req, res) => {
    try {
      const { gameCode, difficulty } = req.params;
      const session = await storage.getGameSession(gameCode);
      
      if (!session) {
        return res.status(404).json({ message: "Game not found" });
      }

      const questionHistory: number[] = JSON.parse(session.questionHistory || "[]");
      const question = await storage.getRandomQuestion(difficulty, questionHistory, session.category);
      
      if (!question) {
        return res.status(404).json({ message: "No more questions available for this difficulty and category" });
      }

      res.json(question);
    } catch (error) {
      console.error("Error fetching question:", error);
      res.status(500).json({ message: "Internal server error" });
    }
  });

  // Update game session (for scoring, team changes, etc.)
  app.put("/api/games/:gameCode", async (req, res) => {
    try {
      const { gameCode } = req.params;
      const updates = req.body;

      // Convert teams array to JSON string if provided
      if (updates.teams) {
        updates.teams = JSON.stringify(updates.teams);
      }

      // Convert questionHistory array to JSON string if provided
      if (updates.questionHistory) {
        updates.questionHistory = JSON.stringify(updates.questionHistory);
      }

      // Convert detailedHistory array to JSON string if provided
      if (updates.detailedHistory) {
        updates.detailedHistory = JSON.stringify(updates.detailedHistory);
      }

      const session = await storage.updateGameSession(gameCode, updates);
      
      if (!session) {
        return res.status(404).json({ message: "Game not found" });
      }

      // Parse teams, questionHistory, and detailedHistory back to objects for response
      const teams: Team[] = JSON.parse(session.teams || "[]");
      const questionHistory: number[] = JSON.parse(session.questionHistory || "[]");
      const detailedHistory = JSON.parse(session.detailedHistory || "[]");

      res.json({
        ...session,
        teams,
        questionHistory,
        detailedHistory,
      });
    } catch (error) {
      console.error("Error updating game:", error);
      res.status(500).json({ message: "Internal server error" });
    }
  });

  // Delete game session
  app.delete("/api/games/:gameCode", async (req, res) => {
    try {
      const { gameCode } = req.params;
      const deleted = await storage.deleteGameSession(gameCode);
      
      if (!deleted) {
        return res.status(404).json({ message: "Game not found" });
      }

      res.json({ message: "Game deleted successfully" });
    } catch (error) {
      console.error("Error deleting game:", error);
      res.status(500).json({ message: "Internal server error" });
    }
  });

  // Get all questions (for debugging)
  app.get("/api/questions", async (req, res) => {
    try {
      const questions = await storage.getAllQuestions();
      res.json(questions);
    } catch (error) {
      console.error("Error fetching questions:", error);
      res.status(500).json({ message: "Internal server error" });
    }
  });

  const httpServer = createServer(app);
  return httpServer;
}
