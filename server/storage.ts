import { users, triviaQuestions, gameSession, type User, type InsertUser, type TriviaQuestion, type InsertTriviaQuestion, type GameSession, type InsertGameSession, type Team } from "@shared/schema";

export interface IStorage {
  getUser(id: number): Promise<User | undefined>;
  getUserByUsername(username: string): Promise<User | undefined>;
  createUser(user: InsertUser): Promise<User>;
  
  // Trivia Questions
  getAllQuestions(): Promise<TriviaQuestion[]>;
  getQuestionsByDifficulty(difficulty: string): Promise<TriviaQuestion[]>;
  getRandomQuestion(difficulty: string, excludeIds: number[]): Promise<TriviaQuestion | undefined>;
  
  // Game Sessions
  createGameSession(session: InsertGameSession): Promise<GameSession>;
  getGameSession(gameCode: string): Promise<GameSession | undefined>;
  updateGameSession(gameCode: string, updates: Partial<GameSession>): Promise<GameSession | undefined>;
  deleteGameSession(gameCode: string): Promise<boolean>;
}

export class MemStorage implements IStorage {
  private users: Map<number, User>;
  private questions: Map<number, TriviaQuestion>;
  private gameSessions: Map<string, GameSession>;
  private currentUserId: number;
  private currentQuestionId: number;
  private currentSessionId: number;

  constructor() {
    this.users = new Map();
    this.questions = new Map();
    this.gameSessions = new Map();
    this.currentUserId = 1;
    this.currentQuestionId = 1;
    this.currentSessionId = 1;
    this.loadTriviaData();
  }

  private loadTriviaData() {
    // Load the trivia questions from the CSV data
    const triviaData = [
      { difficulty: "Easy", question: "Who was the first man created by God?", answer: "Adam", reference: "Genesis 2:7" },
      { difficulty: "Easy", question: "What did God create on the first day?", answer: "Light", reference: "Genesis 1:3" },
      { difficulty: "Easy", question: "Who built an ark to survive the flood?", answer: "Noah", reference: "Genesis 6:14" },
      { difficulty: "Easy", question: "What was the name of Abraham's son?", answer: "Isaac", reference: "Genesis 21:3" },
      { difficulty: "Easy", question: "What sign did God give after the flood?", answer: "Rainbow", reference: "Genesis 9:13" },
      { difficulty: "Medium", question: "Who interpreted Pharaoh's dreams about the famine?", answer: "Joseph", reference: "Genesis 41:15-16" },
      { difficulty: "Medium", question: "What sea did Moses and the Israelites cross?", answer: "Red Sea", reference: "Exodus 14:21" },
      { difficulty: "Medium", question: "Who led the Israelites into the Promised Land?", answer: "Joshua", reference: "Joshua 1:1-2" },
      { difficulty: "Medium", question: "What food did God provide in the desert?", answer: "Manna", reference: "Exodus 16:15" },
      { difficulty: "Medium", question: "Which woman became queen and saved her people?", answer: "Esther", reference: "Esther 4:14" },
      { difficulty: "Hard", question: "Who was the left-handed judge who killed King Eglon?", answer: "Ehud", reference: "Judges 3:15-21" },
      { difficulty: "Hard", question: "What prophet saw a vision of a valley of dry bones?", answer: "Ezekiel", reference: "Ezekiel 37:1-10" },
      { difficulty: "Hard", question: "Who was the prophet taken to heaven in a whirlwind?", answer: "Elijah", reference: "2 Kings 2:11" },
      { difficulty: "Hard", question: "Which apostle survived a snake bite on Malta?", answer: "Paul", reference: "Acts 28:3-6" },
      { difficulty: "Hard", question: "Who was the high priest when Samuel was a boy?", answer: "Eli", reference: "1 Samuel 1:9" },
    ];

    triviaData.forEach((q) => {
      const question: TriviaQuestion = {
        id: this.currentQuestionId++,
        difficulty: q.difficulty,
        question: q.question,
        answer: q.answer,
        reference: q.reference,
      };
      this.questions.set(question.id, question);
    });
  }

  async getUser(id: number): Promise<User | undefined> {
    return this.users.get(id);
  }

  async getUserByUsername(username: string): Promise<User | undefined> {
    return Array.from(this.users.values()).find(
      (user) => user.username === username,
    );
  }

  async createUser(insertUser: InsertUser): Promise<User> {
    const id = this.currentUserId++;
    const user: User = { ...insertUser, id };
    this.users.set(id, user);
    return user;
  }

  async getAllQuestions(): Promise<TriviaQuestion[]> {
    return Array.from(this.questions.values());
  }

  async getQuestionsByDifficulty(difficulty: string): Promise<TriviaQuestion[]> {
    return Array.from(this.questions.values()).filter(
      (q) => q.difficulty.toLowerCase() === difficulty.toLowerCase()
    );
  }

  async getRandomQuestion(difficulty: string, excludeIds: number[] = []): Promise<TriviaQuestion | undefined> {
    const questions = await this.getQuestionsByDifficulty(difficulty);
    const availableQuestions = questions.filter(q => !excludeIds.includes(q.id));
    
    if (availableQuestions.length === 0) return undefined;
    
    const randomIndex = Math.floor(Math.random() * availableQuestions.length);
    return availableQuestions[randomIndex];
  }

  async createGameSession(session: InsertGameSession): Promise<GameSession> {
    const id = this.currentSessionId++;
    const gameSession: GameSession = {
      ...session,
      id,
      createdAt: new Date(),
    };
    this.gameSessions.set(session.gameCode, gameSession);
    return gameSession;
  }

  async getGameSession(gameCode: string): Promise<GameSession | undefined> {
    return this.gameSessions.get(gameCode);
  }

  async updateGameSession(gameCode: string, updates: Partial<GameSession>): Promise<GameSession | undefined> {
    const session = this.gameSessions.get(gameCode);
    if (!session) return undefined;

    const updatedSession = { ...session, ...updates };
    this.gameSessions.set(gameCode, updatedSession);
    return updatedSession;
  }

  async deleteGameSession(gameCode: string): Promise<boolean> {
    return this.gameSessions.delete(gameCode);
  }
}

export const storage = new MemStorage();
