import { Switch, Route } from "wouter";
import { useEffect } from "react";
import { queryClient } from "./lib/queryClient";
import { QueryClientProvider } from "@tanstack/react-query";
import { Toaster } from "@/components/ui/toaster";
import { TooltipProvider } from "@/components/ui/tooltip";
import NotFound from "@/pages/not-found";
import Home from "@/pages/home";
import { AdminPage } from "@/pages/admin";
import { staticGameService } from "@/services/static-game-service";

function Router() {
  return (
    <Switch>
      <Route path="/" component={Home} />
      <Route path="/admin" component={AdminPage} />
      <Route component={NotFound} />
    </Switch>
  );
}

function App() {
  // Load manifest on app start
  useEffect(() => {
    console.log('App started, loading manifest...');
    staticGameService.loadManifest()
      .then(() => console.log('Manifest loaded in App component'))
      .catch((error) => {
        console.error('Failed to load manifest in App component:', error);
        // Continue anyway - the error will be handled by individual components
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
