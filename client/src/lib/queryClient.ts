// Simplified for static mode - no longer using React Query
import { staticGameService } from "@/services/static-game-service";

// Helper function to simulate API calls for components that still expect them
export async function apiRequest(path: string, options?: any) {
  // Route to appropriate static service method
  if (path.includes('/api/games') && options?.method === 'POST') {
    return staticGameService.createGame(options.body);
  }
  
  if (path.includes('/api/games/') && path.includes('/question')) {
    const gameCode = path.split('/')[3];
    return staticGameService.getRandomQuestion(gameCode, options?.body?.difficulty || 'Easy');
  }
  
  if (path.includes('/api/games/')) {
    const gameCode = path.split('/')[3];
    if (options?.method === 'PATCH') {
      return staticGameService.updateGame(gameCode, options.body);
    }
    return staticGameService.getGame(gameCode);
  }
  
  throw new Error(`Unsupported API path: ${path}`);
}