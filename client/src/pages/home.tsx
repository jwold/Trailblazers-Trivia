import { useState } from "react";
import GameSetup from "../components/game-setup";
import GameInterface from "../components/game-interface";
import VictoryScreen from "../components/victory-screen";
import { BookOpen, HelpCircle, X } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

type GamePhase = "setup" | "playing" | "victory";

export default function Home() {
  const [gamePhase, setGamePhase] = useState<GamePhase>("setup");
  const [gameCode, setGameCode] = useState<string>("");
  const [showRules, setShowRules] = useState(false);

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
      <main className="container mx-auto px-4 py-6 max-w-3xl">
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
      
      {/* How to Play Button */}
      <div className="fixed bottom-4 right-4 z-40">
        <Button
          onClick={() => setShowRules(!showRules)}
          className="bg-gray-600 hover:bg-gray-700 text-white rounded-full p-3 shadow-lg"
          size="sm"
        >
          <HelpCircle size={20} />
        </Button>
      </div>

      {/* Rules Overlay */}
      {showRules && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <Card className="max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-4">
              <CardTitle className="text-xl font-bold text-gray-800">How to Play Trailblazers Trivia</CardTitle>
              <Button
                onClick={() => setShowRules(false)}
                variant="ghost"
                size="sm"
                className="text-gray-600 hover:text-gray-800"
              >
                <X size={20} />
              </Button>
            </CardHeader>
            <CardContent className="space-y-4 text-gray-700">
              <div>
                <h3 className="font-semibold text-gray-800 mb-2">Game Setup</h3>
                <ul className="list-disc list-inside space-y-1 text-sm">
                  <li>Create 2-6 teams with unique names</li>
                  <li>Set a target score between 10-50 points</li>
                  <li>Teams are automatically assigned biblical names</li>
                  <li>The game randomly selects which team goes first</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-gray-800 mb-2">Gameplay</h3>
                <ul className="list-disc list-inside space-y-1 text-sm">
                  <li>Teams take turns answering Bible trivia questions</li>
                  <li>Choose between Easy (1 point) or Hard (3 points) questions</li>
                  <li>The game leader reads the question aloud to the active team</li>
                  <li>Answers are blurred by default - tap the eye icon to reveal them</li>
                  <li>Mark answers as correct, incorrect, or skip to the next question</li>
                  <li>Teams alternate turns after each question, regardless of correctness</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-gray-800 mb-2">Scoring</h3>
                <ul className="list-disc list-inside space-y-1 text-sm">
                  <li><strong>Easy Questions:</strong> 1 point each</li>
                  <li><strong>Hard Questions:</strong> 3 points each</li>
                  <li>Only correct answers earn points</li>
                  <li>Incorrect or skipped questions earn no points</li>
                  <li>First team to reach the target score wins!</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-gray-800 mb-2">Features</h3>
                <ul className="list-disc list-inside space-y-1 text-sm">
                  <li>Edit team names during gameplay by clicking the edit icon</li>
                  <li>View question history to see previous questions and answers</li>
                  <li>Visual feedback animations for correct and incorrect answers</li>
                  <li>Bible references provided with each question for learning</li>
                  <li>Mobile-friendly interface optimized for touch screens</li>
                </ul>
              </div>

              <div className="bg-gray-50 p-3 rounded-lg">
                <h3 className="font-semibold text-gray-800 mb-2">Game Leader Tips</h3>
                <ul className="list-disc list-inside space-y-1 text-sm">
                  <li>Read questions clearly and give teams time to think</li>
                  <li>Use the Bible references to discuss answers and teach</li>
                  <li>Keep the game moving - don't spend too long on one question</li>
                  <li>Encourage teamwork and discussion within teams</li>
                  <li>Have fun and celebrate correct answers together!</li>
                </ul>
              </div>
            </CardContent>
          </Card>
        </div>
      )}
      
      {/* Confetti Container - Hidden */}
      <div id="confetti-container" className="fixed inset-0 pointer-events-none z-50 hidden"></div>
    </div>
  );
}
