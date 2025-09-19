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
    <div className="min-h-screen overflow-x-hidden bg-gray-50 transition-colors">
      {/* Header */}
      <header className="sticky top-0 z-40 bg-white border-b border-gray-200">
        <div className="px-4 py-3">
          <div className="flex items-center justify-between">
            {/* Logo and Title */}
            <div
              className="cursor-pointer"
              onClick={() => {
                setGamePhase("setup");
                // Keep gameCode so Resume button can appear in header
              }}
            >
              <h1 className="text-xl font-semibold text-gray-900">Trailblazers Trivia</h1>
            </div>

            {/* Header Right Side - Resume Game, End Game and Buttons */}
            <div className="flex items-center gap-2">
              {gamePhase === "setup" && gameCode && (
                <Button
                  onClick={() => setGamePhase("playing")}
                  className="bg-blue-500 hover:bg-blue-600 text-white py-1.5 px-3 text-sm font-medium rounded-full transition-all duration-200"
                >
                  Resume
                </Button>
              )}
              {gamePhase === "playing" && (
                <Button
                  onClick={handleGameEnd}
                  className="bg-gray-100 hover:bg-gray-200 text-gray-700 py-1.5 px-3 text-sm font-medium rounded-full transition-all duration-200"
                >
                  End Game
                </Button>
              )}
            </div>
          </div>
        </div>
      </header>
      {/* Main Content */}
      <main className="container mx-auto px-4 py-6 max-w-lg">
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
