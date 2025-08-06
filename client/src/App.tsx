import { Switch, Route, Router as WouterRouter } from "wouter";
import { useEffect } from "react";
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
  // Load manifest on app start
  useEffect(() => {
    staticGameService.loadManifest()
      .catch((error) => {
        console.error('Failed to load manifest:', error);
      });
  }, []);
  
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
