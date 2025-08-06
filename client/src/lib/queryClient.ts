import { QueryClient, QueryFunction } from "@tanstack/react-query";
import { staticGameService } from "@/services/static-game-service";

async function throwIfResNotOk(res: Response) {
  if (!res.ok) {
    const text = (await res.text()) || res.statusText;
    throw new Error(`${res.status}: ${text}`);
  }
}

export async function apiRequest(
  method: string,
  url: string,
  data?: unknown | undefined,
): Promise<Response> {
  // Intercept API calls and route to static service
  const urlParts = url.split('/').filter(Boolean);
  
  try {
    // Handle different API endpoints
    if (url.includes('/api/games') && method === 'POST') {
      // Create new game
      const result = await staticGameService.createGame(data as any);
      return new Response(JSON.stringify(result), { status: 200 });
    }
    
    if (url.match(/\/api\/games\/\w+$/) && method === 'GET') {
      // Get game by code
      const gameCode = urlParts[urlParts.length - 1];
      const game = await staticGameService.getGame(gameCode);
      return new Response(JSON.stringify(game), { status: 200 });
    }
    
    if (url.match(/\/api\/games\/\w+$/) && method === 'PUT') {
      // Update game
      const gameCode = urlParts[urlParts.length - 1];
      const game = await staticGameService.updateGame(gameCode, data as any);
      return new Response(JSON.stringify(game), { status: 200 });
    }
    
    if (url.match(/\/api\/games\/\w+\/question\/(Easy|Hard)/)) {
      // Get random question
      const gameCode = urlParts[urlParts.length - 3];
      const difficulty = urlParts[urlParts.length - 1] as 'Easy' | 'Hard';
      const question = await staticGameService.getRandomQuestion(gameCode, difficulty);
      return new Response(JSON.stringify(question), { status: 200 });
    }
    
    if (url === '/api/questions') {
      // Get all questions (for admin)
      const questions = await staticGameService.getQuestions();
      return new Response(JSON.stringify(questions), { status: 200 });
    }
    
    if (url.match(/\/api\/questions\/\d+/) && method === 'PUT') {
      // Update question (not supported)
      throw new Error('Editing not supported in static mode');
    }
    
    if (url.match(/\/api\/questions\/\d+/) && method === 'DELETE') {
      // Delete question (not supported)
      throw new Error('Deleting not supported in static mode');
    }
    
    if (url === '/api/questions' && method === 'POST') {
      // Create question (not supported)
      throw new Error('Creating questions not supported in static mode');
    }
    
    // Fallback to regular fetch for other URLs
    const res = await fetch(url, {
      method,
      headers: data ? { "Content-Type": "application/json" } : {},
      body: data ? JSON.stringify(data) : undefined,
      credentials: "include",
    });

    await throwIfResNotOk(res);
    return res;
  } catch (error) {
    // Convert errors to Response objects
    return new Response(JSON.stringify({ error: (error as Error).message }), { 
      status: 400,
      statusText: (error as Error).message 
    });
  }
}

type UnauthorizedBehavior = "returnNull" | "throw";
export const getQueryFn: <T>(options: {
  on401: UnauthorizedBehavior;
}) => QueryFunction<T> =
  ({ on401: unauthorizedBehavior }) =>
  async ({ queryKey }) => {
    console.log('Query function called with key:', queryKey);
    
    // For game queries, route through apiRequest for proper static handling
    const url = queryKey.join("/") as string;
    
    try {
      const res = await apiRequest("GET", url);
      
      if (unauthorizedBehavior === "returnNull" && res.status === 401) {
        return null;
      }

      await throwIfResNotOk(res);
      const data = await res.json();
      console.log('Query successful for:', url, data);
      return data;
    } catch (error) {
      console.error('Query failed for:', url, error);
      throw error;
    }
  };

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      queryFn: getQueryFn({ on401: "throw" }),
      refetchInterval: false,
      refetchOnWindowFocus: false,
      staleTime: Infinity,
      retry: false,
    },
    mutations: {
      retry: false,
    },
  },
});
