import { useState } from "react";
import GameSetup from "../components/game-setup";
import GameInterface from "../components/game-interface-simple";
import VictoryScreen from "../components/victory-screen";
import { BookOpen, X, Settings } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Link } from "wouter";

type GamePhase = "setup" | "playing" | "victory";

export default function Home() {
  const [gamePhase, setGamePhase] = useState<GamePhase>("setup");
  const [gameCode, setGameCode] = useState<string>("");

  const handleGameStart = (code: string) => {
    setGameCode(code);
    setGamePhase("playing");
  };

  const handleGameEnd = () => {
    setGamePhase("victory");
  };

  const handleNewGame = () => {
    setGamePhase("setup");
    setGameCode("");
  };

  const handlePlayAgain = () => {
    setGamePhase("playing");
  };

  return (
    <div className="min-h-screen overflow-x-hidden bg-white transition-colors">
      {/* Header */}
      <header className="sticky top-0 z-40 bg-white border-b-4 border-gray-300">
        <div className="px-4 py-4">
          <div className="flex items-center justify-between">
            {/* Logo and Title */}
            <div 
              className="flex items-center gap-3 cursor-pointer hover:opacity-80 transition-opacity duration-200"
              onClick={() => {
                setGamePhase("setup");
                // Keep gameCode so Resume button can appear in header
              }}
            >
              <div className="w-10 h-10 bg-gray-600 rounded-lg flex items-center justify-center">
                <svg viewBox="0 0 24 24" className="w-6 h-6 text-white" fill="currentColor">
                  <path d="M12 2L2 7V17C2 18.1 2.9 19 4 19H8V12H16V19H20C21.1 19 22 18.1 22 17V7L12 2Z"/>
                  <path d="M8 19V21C8 22.1 8.9 23 10 23H14C15.1 23 16 22.1 16 21V19H8Z"/>
                </svg>
              </div>
              <h1 className="text-2xl font-bold text-gray-900">Trailblazers Trivia</h1>
            </div>
            
            {/* Header Right Side - Resume Game, End Game and Buttons */}
            <div className="flex items-center gap-3">
              {gamePhase === "setup" && gameCode && (
                <Button
                  onClick={() => setGamePhase("playing")}
                  className="bg-gray-500 hover:bg-gray-600 text-white py-2 px-4 font-semibold transition-all duration-200"
                >
                  Resume Game
                </Button>
              )}
              {gamePhase === "playing" && (
                <Button
                  onClick={handleGameEnd}
                  className="bg-gray-200 hover:bg-gray-300 text-gray-700 py-2 px-4 font-semibold transition-all duration-200"
                >
                  End Game
                </Button>
              )}
            </div>
          </div>
        </div>
      </header>
      {/* Hero Banner - Only show on setup phase */}
      {gamePhase === "setup" && (
        <div className="bg-gray-200 relative overflow-hidden border-b-2 border-gray-300">
          <div className="container mx-auto px-4 py-6 max-w-3xl relative z-10">
            <div className="text-center">
              {/* Floating Bible Icons */}
              <div className="absolute top-4 left-8 opacity-30 animate-bounce">
                <BookOpen size={32} className="transform rotate-12 text-gray-500" />
              </div>
              <div className="absolute top-8 right-12 opacity-30 animate-bounce delay-300">
                <BookOpen size={24} className="transform -rotate-12 text-gray-500" />
              </div>
              <div className="absolute bottom-6 left-16 opacity-30 animate-bounce delay-500">
                <BookOpen size={28} className="transform rotate-6 text-gray-500" />
              </div>
              <div className="absolute bottom-4 right-8 opacity-30 animate-bounce delay-700">
                <BookOpen size={20} className="transform -rotate-6 text-gray-500" />
              </div>
              
              {/* Main Content */}
              <div className="relative">
                <h2 className="text-3xl md:text-4xl font-bold mb-3 text-gray-900">Epic Trivia Battles</h2>
                <p className="text-lg md:text-xl mb-4 text-gray-700 font-medium">Challenge your teams • Test knowledge • Have amazing fun!</p>
                
              </div>
            </div>
          </div>
          
          {/* Background Pattern */}
          <div className="absolute inset-0 opacity-10">
            <div className="absolute top-0 left-0 w-full h-full">
              <svg viewBox="0 0 100 100" className="w-full h-full">
                <defs>
                  <pattern id="crosses" patternUnits="userSpaceOnUse" width="20" height="20">
                    <path d="M10 5 L10 15 M5 10 L15 10" stroke="gray" strokeWidth="0.5" fill="none"/>
                  </pattern>
                </defs>
                <rect width="100" height="100" fill="url(#crosses)" />
              </svg>
            </div>
          </div>
        </div>
      )}
      {/* Main Content */}
      <main className="container mx-auto px-4 py-6 max-w-3xl bg-white">
        {gamePhase === "setup" && (
          <GameSetup 
            onGameStart={handleGameStart} 
            activeGameCode={gameCode}
            onResumeGame={() => setGamePhase("playing")}
          />
        )}
        
        {gamePhase === "playing" && gameCode && (
          <GameInterface 
            gameCode={gameCode} 
            onGameEnd={handleGameEnd}
          />
        )}
        
        {gamePhase === "victory" && gameCode && (
          <VictoryScreen 
            gameCode={gameCode}
            onNewGame={handleNewGame}
          />
        )}
      </main>
      {/* Confetti Container - Hidden */}
      <div id="confetti-container" className="fixed inset-0 pointer-events-none z-50 hidden"></div>
    </div>
  );
}
