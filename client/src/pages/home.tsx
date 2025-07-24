import { useState } from "react";
import GameSetup from "../components/game-setup";
import GameInterface from "../components/game-interface";
import VictoryScreen from "../components/victory-screen";
import { BookOpen } from "lucide-react";
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
        <div className="px-4 py-4">
          <div className="text-center">
            <h1 className="text-2xl font-bold text-gray-800">Trailblazers Trivia</h1>
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
          />
        )}
      </main>
      {/* Confetti Container */}
      <div id="confetti-container" className="fixed inset-0 pointer-events-none z-50"></div>
    </div>
  );
}
