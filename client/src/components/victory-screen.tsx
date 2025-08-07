import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Crown, Trophy, Share } from "lucide-react";
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
      <Card className="bg-gray-200 dark:bg-gray-800 border-4 border-gray-300 dark:border-gray-700 shadow-xl">
        <CardContent className="p-8 text-center">
          <div className="bounce-slow mb-4">
            <Crown className="mx-auto text-gray-600 dark:text-gray-400" size={64} />
          </div>
          <h2 className="text-4xl font-bold mb-4 text-gray-800 dark:text-gray-100">🎉 Yay! 🎉</h2>
          <h3 className="text-2xl font-semibold mb-2 text-gray-700 dark:text-gray-200">{winningTeam.name}</h3>
        </CardContent>
      </Card>
      {/* Final Scoreboard */}
      <Card className="border-4 border-gray-200 dark:border-gray-700 shadow-xl">
        <CardContent className="p-6">
          <h3 className="text-2xl font-bold text-gray-800 dark:text-gray-100 mb-6 text-center">Final Scoreboard</h3>
          <div className="space-y-4">
            {sortedTeams.map((team, index) => {
              const colorClass = "bg-gray-50 dark:bg-gray-800 border-gray-200 dark:border-gray-700";
              const textClass = "text-gray-800 dark:text-gray-200";
              const medalColor = index === 0 ? "bg-yellow-500 dark:bg-yellow-600" :
                                index === 1 ? "bg-gray-400 dark:bg-gray-500" :
                                index === 2 ? "bg-orange-600 dark:bg-orange-700" :
                                "bg-gray-300 dark:bg-gray-600";

              return (
                <div key={team.id} className={`flex items-center justify-between ${colorClass} p-4 rounded-xl border-2`}>
                  <div className="flex items-center">
                    <div className={`${medalColor} text-white w-10 h-10 rounded-full flex items-center justify-center font-bold text-lg mr-4`}>
                      {index + 1}
                    </div>
                    <div>
                      <h4 className={`font-bold ${textClass} text-lg`}>{team.name}</h4>
                      <p className="text-gray-600 dark:text-gray-400" style={{ fontSize: '0.875rem' }}>
                        {team.correctAnswers} correct
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center space-x-2">
                    {index === 0 && <Trophy className="text-yellow-600 dark:text-yellow-500" size={24} />}
                    <div className={`text-3xl font-bold ${textClass}`}>{team.score}</div>
                  </div>
                </div>
              );
            })}
          </div>
        </CardContent>
      </Card>
      {/* Game Stats */}
      <Card className="border-4 border-gray-200 shadow-xl hidden">
        <CardContent className="p-6">
          <h3 className="text-xl font-bold text-gray-800 mb-4">Game Summary</h3>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div className="text-center p-4 bg-gray-50 rounded-xl">
              <div className="text-2xl font-bold text-gray-700">{totalQuestions}</div>
              <p className="text-gray-800 font-medium">Questions Asked</p>
            </div>
            <div className="text-center p-4 bg-gray-100 rounded-xl">
              <div className="text-2xl font-bold text-gray-700">{totalCorrectAnswers}</div>
              <p className="text-gray-800 font-medium">Correct Answers</p>
            </div>
            <div className="text-center p-4 bg-gray-50 rounded-xl">
              <div className="text-2xl font-bold text-gray-700">{winningTeam.score}</div>
              <p className="text-gray-800 font-medium">Winning Score</p>
            </div>
            <div className="text-center p-4 bg-gray-100 rounded-xl">
              <div className="text-2xl font-bold text-gray-700">{gameSession.targetScore}</div>
              <p className="text-gray-800 font-medium">Target Score</p>
            </div>
          </div>
        </CardContent>
      </Card>
      {/* New Game Button */}
      <div className="flex justify-center mb-4">
        <Button
          onClick={onNewGame}
          className="bg-gradient-to-r from-gray-600 to-gray-700 text-white py-8 px-8 text-xl font-semibold hover:from-gray-700 hover:to-gray-800 transition-all duration-200 transform hover:scale-105 border-4 border-white/20"
          style={{ minWidth: '200px' }}
        >
          New Game
        </Button>
      </div>
      
      {/* Share Results Button */}
      <div className="text-center">
        <Button 
          className="bg-gray-200 dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600 text-gray-700 dark:text-gray-200 py-4 px-6 font-semibold transition-all duration-200"
          onClick={() => {
            const shareText = `🎉 ${winningTeam.name} won our Bible Trivia Quest with ${winningTeam.score} points! Can you beat our score? 📖✨`;
            if (navigator.share) {
              navigator.share({
                title: "Bible Trivia Quest Victory!",
                text: shareText,
              });
            } else {
              navigator.clipboard.writeText(shareText);
              alert("Victory message copied to clipboard!");
            }
          }}
        >
          <Share className="mr-2" size={16} />
          Share Results
        </Button>
      </div>
    </div>
  );
}