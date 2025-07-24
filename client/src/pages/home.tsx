import { useState } from "react";
import GameSetup from "../components/game-setup";
import GameInterface from "../components/game-interface";
import VictoryScreen from "../components/victory-screen";
import { BookOpen, HelpCircle } from "lucide-react";
import { Button } from "@/components/ui/button";

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
    <div className="min-h-screen">
      {/* Header */}
      <header className="bg-white shadow-lg border-b-4 border-brand-blue sticky top-0 z-50">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="bg-gradient-to-r from-brand-blue to-brand-green p-3 rounded-full">
                <BookOpen className="text-white text-2xl" size={24} />
              </div>
              <div>
                <h1 className="text-2xl font-bold text-gray-800">Bible Trivia Quest</h1>
                <p className="text-sm text-gray-600">Fun Bible Games for Kids!</p>
              </div>
            </div>
            <div className="flex space-x-2">
              <Button variant="ghost" size="sm" className="bg-gray-100 hover:bg-gray-200">
                <HelpCircle className="text-gray-600" size={16} />
              </Button>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="container mx-auto px-4 py-6 max-w-4xl">
        {gamePhase === "setup" && (
          <GameSetup onGameStart={handleGameStart} />
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
            onPlayAgain={handlePlayAgain}
          />
        )}
      </main>

      {/* Confetti Container */}
      <div id="confetti-container" className="fixed inset-0 pointer-events-none z-50"></div>
    </div>
  );
}
