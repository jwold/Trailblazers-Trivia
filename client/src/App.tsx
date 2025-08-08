import { Switch, Route, Router as WouterRouter } from "wouter";
import { useEffect, useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Toaster } from "@/components/ui/toaster";
import { TooltipProvider } from "@/components/ui/tooltip";
import NotFound from "@/pages/not-found";
import Home from "@/pages/home";
import { AdminPage } from "@/pages/admin";
import { staticGameService } from "@/services/static-game-service";

const queryClient = new QueryClient();

function Router() {
  // Get base path for GitHub Pages
  const base = import.meta.env.BASE_URL || '/';
  
  return (
    <WouterRouter base={base}>
      <Switch>
        <Route path="/" component={Home} />
        <Route path="/admin" component={AdminPage} />
        <Route component={NotFound} />
      </Switch>
    </WouterRouter>
  );
}

function App() {
  const [manifestError, setManifestError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  
  // Load manifest on app start
  useEffect(() => {
    console.log('App starting, loading manifest...');
    staticGameService.loadManifest()
      .then(() => {
        console.log('Manifest loaded successfully');
        setIsLoading(false);
      })
      .catch((error) => {
        console.error('Failed to load manifest:', error);
        setManifestError(error.message);
        setIsLoading(false);
        // Continue anyway - app can still function
      });
  }, []);
  
  if (isLoading) {
    return <div style={{ padding: '20px' }}>Loading Trailblazers Trivia...</div>;
  }
  
  if (manifestError) {
    return (
      <div style={{ padding: '20px', color: 'red' }}>
        <h2>Error Loading App</h2>
        <p>{manifestError}</p>
        <button onClick={() => window.location.reload()}>Retry</button>
      </div>
    );
  }
  
  return (
    <QueryClientProvider client={queryClient}>
      <TooltipProvider>
        <Toaster />
        <Router />
      </TooltipProvider>
    </QueryClientProvider>
  );
}

export default App;
