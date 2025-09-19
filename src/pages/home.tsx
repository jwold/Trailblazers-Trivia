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
    <div className="min-h-screen overflow-x-hidden bg-gray-50">
      {/* iOS Style Navigation Bar */}
      <header className="bg-white/80 backdrop-blur-md">
        {/* Status Bar Space */}
        <div className="h-12 bg-white/80" />

        {/* Navigation Content */}
        <div className="px-4">
          {gamePhase === "setup" ? (
            // Large Title Style for Setup
            <div className="py-2">
              {/* Settings button hidden for now */}
              <h1 className="text-3xl font-bold text-gray-900 tracking-tight">
                Trailblazers Trivia
              </h1>
            </div>
          ) : (
            // Compact Style for Playing/Victory
            <div className="flex items-center justify-between py-3">
              <button
                onClick={() => setGamePhase("setup")}
                className="text-blue-500 active:opacity-60 transition-opacity"
              >
                <span className="text-lg">‹ Back</span>
              </button>
              <h1 className="text-lg font-semibold text-gray-900">
                {gamePhase === "playing" ? "Game" : "Results"}
              </h1>
              <button
                onClick={() => gamePhase === "playing" ? handleGameEnd() : null}
                className="text-blue-500 active:opacity-60 transition-opacity"
              >
                <span className="text-base">
                  {gamePhase === "playing" ? "End" : ""}
                </span>
              </button>
            </div>
          )}
        </div>
        <div className="border-b border-gray-200/50" />
      </header>
      {/* Main Content with iOS Safe Areas */}
      <main className="flex-1 px-4 pb-8">
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
