import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Crown, Trophy } from "lucide-react";
import { type Team, type ClientGameSession, staticGameService } from "@/services/static-game-service";
import { useEffect, useState } from "react";

interface VictoryScreenProps {
  gameCode: string;
  onNewGame: () => void;
}

export default function VictoryScreen({ gameCode, onNewGame }: VictoryScreenProps) {
  const [gameSession, setGameSession] = useState<ClientGameSession | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const loadGame = async () => {
      try {
        const session = await staticGameService.getGame(gameCode);
        setGameSession(session);
      } catch (error) {
        console.error('Failed to load game session:', error);
      } finally {
        setIsLoading(false);
      }
    };
    loadGame();
  }, [gameCode]);

  if (isLoading || !gameSession) {
    return <div className="text-center py-8">Loading results...</div>;
  }

  const teams: Team[] = gameSession.teams;
  const sortedTeams = [...teams].sort((a, b) => b.score - a.score);
  const winningTeam = sortedTeams[0];

  const totalQuestions = gameSession.questionHistory.length;
  const totalCorrectAnswers = teams.reduce((sum, team) => sum + team.correctAnswers, 0);

  return (
    <div className="space-y-6">
      {/* Winner Announcement */}
      <div className="bg-white rounded-2xl p-8 text-center shadow-sm">
        <Trophy className="text-yellow-500 w-16 h-16 mx-auto mb-4" />
        <h2 className="text-3xl font-bold text-gray-900 mb-2">{winningTeam.name} Wins!</h2>
        <p className="text-gray-500 text-lg">{winningTeam.score} points</p>
      </div>

      {/* Final Scoreboard */}
      <div className="bg-white rounded-2xl p-6 shadow-sm">
        <h3 className="text-xl font-semibold text-gray-900 mb-4">Final Scores</h3>
        <div className="space-y-3">
          {sortedTeams.map((team, index) => {
            const isWinner = index === 0;
            const bgColor = isWinner ? "bg-yellow-50 border-yellow-200" : "bg-gray-50";

            return (
              <div key={team.id} className={`flex items-center justify-between ${bgColor} p-4 rounded-xl ${isWinner ? 'border' : ''}`}>
                <div className="flex items-center gap-3">
                  <div className={`${
                    index === 0 ? 'bg-yellow-500' :
                    index === 1 ? 'bg-gray-400' :
                    index === 2 ? 'bg-orange-500' :
                    'bg-gray-300'
                  } text-white w-8 h-8 rounded-full flex items-center justify-center font-semibold text-sm`}>
                    {index + 1}
                  </div>
                  <div>
                    <h4 className="font-medium text-gray-900">{team.name}</h4>
                    <p className="text-sm text-gray-500">
                      {team.correctAnswers} correct answers
                    </p>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  {isWinner && <Trophy className="text-yellow-500" size={20} />}
                  <div className="text-2xl font-semibold text-gray-900">{team.score}</div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
      {/* New Game Button */}
      <Button
        onClick={onNewGame}
        className="w-full bg-blue-500 hover:bg-blue-600 text-white py-4 px-6 font-semibold rounded-2xl text-lg transition-all duration-200 shadow-sm"
      >
        Start New Game
      </Button>
    </div>
  );
}