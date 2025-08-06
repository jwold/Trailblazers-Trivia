import { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { staticGameService } from "@/services/static-game-service";

interface DebugPanelProps {
  onClose?: () => void;
}

export function DebugPanel({ onClose }: DebugPanelProps) {
  const [debugResults, setDebugResults] = useState<any[]>([]);
  const [isRunning, setIsRunning] = useState(false);

  const addResult = (test: string, result: any, success: boolean = true) => {
    setDebugResults(prev => [...prev, { test, result, success, timestamp: Date.now() }]);
  };

  const runTests = async () => {
    setIsRunning(true);
    setDebugResults([]);

    try {
      // Test 1: Check base path
      addResult("Base Path", window.location.pathname);

      // Test 2: Test manifest loading
      try {
        const manifest = await staticGameService.loadManifest();
        addResult("Manifest Loading", `Successfully loaded ${manifest.categories.length} categories`, true);
      } catch (error) {
        addResult("Manifest Loading", `Failed: ${(error as Error).message}`, false);
      }

      // Test 3: Test question loading
      try {
        const questions = await staticGameService.loadQuestions('bible', 'Easy');
        addResult("Question Loading", `Successfully loaded ${questions.length} bible easy questions`, true);
      } catch (error) {
        addResult("Question Loading", `Failed: ${(error as Error).message}`, false);
      }

      // Test 4: Check localStorage
      const currentGame = localStorage.getItem('currentGame');
      const usedQuestions = localStorage.getItem('usedQuestions');
      addResult("LocalStorage", {
        currentGame: currentGame ? 'Present' : 'Not found',
        usedQuestions: usedQuestions ? 'Present' : 'Not found'
      });

      // Test 5: Test game creation
      try {
        const gameResult = await staticGameService.createGame({
          teams: [
            { id: '1', name: 'Test Team 1', color: 'blue', score: 0, correctAnswers: 0 },
            { id: '2', name: 'Test Team 2', color: 'green', score: 0, correctAnswers: 0 }
          ],
          targetScore: 10,
          gameMode: 'regular',
          category: 'bible'
        });
        addResult("Game Creation", `Game created with code: ${gameResult.gameCode}`, true);
      } catch (error) {
        addResult("Game Creation", `Failed: ${(error as Error).message}`, false);
      }

    } catch (error) {
      addResult("Debug Tests", `Unexpected error: ${(error as Error).message}`, false);
    } finally {
      setIsRunning(false);
    }
  };

  return (
    <Card className="fixed top-4 right-4 w-96 max-h-[80vh] overflow-y-auto z-50 border-4 border-red-500">
      <CardHeader>
        <div className="flex items-center justify-between">
          <CardTitle className="text-red-600">🐛 Debug Panel</CardTitle>
          {onClose && (
            <Button onClick={onClose} size="sm" variant="ghost">
              ✕
            </Button>
          )}
        </div>
      </CardHeader>
      <CardContent>
        <Button 
          onClick={runTests}
          disabled={isRunning}
          className="w-full mb-4 bg-red-600 hover:bg-red-700"
        >
          {isRunning ? 'Running Tests...' : 'Run Debug Tests'}
        </Button>

        <div className="space-y-2">
          {debugResults.map((result, index) => (
            <div 
              key={index}
              className={`p-2 rounded text-xs border ${
                result.success ? 'bg-green-50 border-green-200' : 'bg-red-50 border-red-200'
              }`}
            >
              <div className={`font-semibold ${result.success ? 'text-green-800' : 'text-red-800'}`}>
                {result.success ? '✅' : '❌'} {result.test}
              </div>
              <div className="mt-1 text-gray-700">
                {typeof result.result === 'string' 
                  ? result.result 
                  : JSON.stringify(result.result, null, 2)
                }
              </div>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  );
}