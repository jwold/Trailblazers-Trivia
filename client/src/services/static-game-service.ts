import type { Team, TriviaQuestion, ClientGameSession, GameSetup, QuestionHistoryEntry } from "@shared/schema";

interface QuestionData {
  id: number;
  question: string;
  answer: string;
  reference?: string;
}

interface Manifest {
  categories: string[];
  totalQuestions: number;
  questionCounts: Record<string, {
    easy: number;
    hard: number;
    total: number;
  }>;
}

class StaticGameService {
  private manifest: Manifest | null = null;
  private questionCache: Map<string, QuestionData[]> = new Map();
  private currentGame: ClientGameSession | null = null;
  private usedQuestionIds: Set<number> = new Set();
  
  // Get base path for GitHub Pages
  private getBasePath(): string {
    // Check if we're running in a subdirectory (GitHub Pages style)
    const pathname = window.location.pathname;
    if (pathname.includes('/Trailblazers-Trivia/')) {
      return '/Trailblazers-Trivia/';
    }
    // Use environment variable if available, fallback to root
    return import.meta.env.BASE_URL || '/';
  }

  async loadManifest(): Promise<Manifest> {
    if (this.manifest) return this.manifest;
    
    const basePath = this.getBasePath();
    const manifestUrl = `${basePath}data/manifest.json`;
    console.log('Loading manifest from:', manifestUrl);
    
    try {
      const response = await fetch(manifestUrl);
      if (!response.ok) {
        throw new Error(`Failed to load manifest: ${response.status} ${response.statusText} from ${manifestUrl}`);
      }
      this.manifest = await response.json();
      console.log('Manifest loaded successfully:', this.manifest);
      return this.manifest;
    } catch (error) {
      console.error('Manifest loading failed:', error);
      throw error;
    }
  }

  async loadQuestions(category: string, difficulty: 'Easy' | 'Hard'): Promise<QuestionData[]> {
    const key = `${category}-${difficulty.toLowerCase()}`;
    
    if (this.questionCache.has(key)) {
      console.log(`Questions cache hit for ${key}`);
      return this.questionCache.get(key)!;
    }
    
    const basePath = this.getBasePath();
    const questionUrl = `${basePath}data/${key}.json`;
    console.log(`Loading questions from: ${questionUrl}`);
    
    try {
      const response = await fetch(questionUrl);
      if (!response.ok) {
        throw new Error(`Failed to load questions: ${response.status} ${response.statusText} from ${questionUrl}`);
      }
      const questions = await response.json();
      console.log(`Questions loaded successfully for ${key}:`, questions.length, 'questions');
      this.questionCache.set(key, questions);
      return questions;
    } catch (error) {
      console.error(`Questions loading failed for ${key}:`, error);
      throw error;
    }
  }

  generateGameCode(): string {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code = '';
    for (let i = 0; i < 6; i++) {
      code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return code;
  }

  async createGame(gameSetup: GameSetup & { category: string }): Promise<{ gameCode: string }> {
    const gameCode = this.generateGameCode();
    
    console.log('Creating game with setup:', gameSetup);
    
    this.currentGame = {
      id: Date.now(),
      gameCode,
      teams: gameSetup.teams,
      targetScore: gameSetup.targetScore,
      currentTeamIndex: 0,
      gamePhase: 'playing',
      questionHistory: [],
      detailedHistory: [],
      gameMode: gameSetup.gameMode,
      category: gameSetup.category
    };
    
    // Save to localStorage
    try {
      localStorage.setItem('currentGame', JSON.stringify(this.currentGame));
      localStorage.setItem('usedQuestions', JSON.stringify([]));
      this.usedQuestionIds.clear();
      console.log('Game created and saved to localStorage:', this.currentGame);
    } catch (error) {
      console.error('Failed to save game to localStorage:', error);
      throw error;
    }
    
    return { gameCode };
  }

  async getGame(gameCode: string): Promise<ClientGameSession | null> {
    console.log('Getting game with code:', gameCode);
    
    // Load from localStorage
    const saved = localStorage.getItem('currentGame');
    if (saved) {
      try {
        this.currentGame = JSON.parse(saved);
        console.log('Game loaded from localStorage:', this.currentGame);
        
        // Verify the game code matches
        if (this.currentGame && this.currentGame.gameCode !== gameCode) {
          console.warn('Game code mismatch. Expected:', gameCode, 'Found:', this.currentGame.gameCode);
          return null;
        }
        
        // Load used questions
        const usedQuestions = localStorage.getItem('usedQuestions');
        if (usedQuestions) {
          this.usedQuestionIds = new Set(JSON.parse(usedQuestions));
          console.log('Used questions loaded:', this.usedQuestionIds);
        }
      } catch (error) {
        console.error('Failed to parse saved game from localStorage:', error);
        this.currentGame = null;
      }
    } else {
      console.log('No saved game found in localStorage');
    }
    
    return this.currentGame;
  }

  async updateGame(gameCode: string, updates: Partial<ClientGameSession>): Promise<ClientGameSession> {
    if (!this.currentGame) {
      throw new Error('No active game');
    }
    
    this.currentGame = { ...this.currentGame, ...updates };
    localStorage.setItem('currentGame', JSON.stringify(this.currentGame));
    
    return this.currentGame;
  }

  async getRandomQuestion(gameCode: string, difficulty: 'Easy' | 'Hard'): Promise<TriviaQuestion> {
    if (!this.currentGame) {
      throw new Error('No active game');
    }
    
    const category = this.currentGame.category || 'bible';
    const questions = await this.loadQuestions(category, difficulty);
    
    // Filter out used questions
    const availableQuestions = questions.filter(q => !this.usedQuestionIds.has(q.id));
    
    if (availableQuestions.length === 0) {
      throw new Error('No more questions available');
    }
    
    // Pick a random question
    const randomIndex = Math.floor(Math.random() * availableQuestions.length);
    const selectedQuestion = availableQuestions[randomIndex];
    
    // Mark as used
    this.usedQuestionIds.add(selectedQuestion.id);
    localStorage.setItem('usedQuestions', JSON.stringify(Array.from(this.usedQuestionIds)));
    
    return {
      ...selectedQuestion,
      difficulty,
      category
    };
  }

  // For compatibility with admin features (will be removed)
  async getQuestions(): Promise<TriviaQuestion[]> {
    return [];
  }

  async updateQuestion(id: number, updates: any): Promise<any> {
    throw new Error('Editing not supported in static mode');
  }

  async deleteQuestion(id: number): Promise<any> {
    throw new Error('Deleting not supported in static mode');
  }

  async createQuestion(question: any): Promise<any> {
    throw new Error('Creating questions not supported in static mode');
  }
}

export const staticGameService = new StaticGameService();