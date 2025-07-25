import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { useQuery } from "@tanstack/react-query";
import { Crown, Trophy, Plus, Share } from "lucide-react";
import { type Team, type ClientGameSession } from "@shared/schema";
// import { createConfetti } from "../lib/game-logic";
import { useEffect } from "react";

interface VictoryScreenProps {
  gameCode: string;
  onNewGame: () => void;
}

export default function VictoryScreen({ gameCode, onNewGame }: VictoryScreenProps) {
  const { data: gameSession, isLoading } = useQuery<ClientGameSession>({
    queryKey: ["/api/games", gameCode],
  });

  // useEffect(() => {
  //   // Create celebration effect on mount
  //   createConfetti();
  //   const interval = setInterval(createConfetti, 2000);
  //   return () => clearInterval(interval);
  // }, []);

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
      <Card className="bg-gray-200 border-4 border-gray-300 shadow-xl">
        <CardContent className="p-8 text-center">
          <div className="bounce-slow mb-4">
            <Crown className="mx-auto text-gray-600" size={64} />
          </div>
          <h2 className="text-4xl font-bold mb-4 text-gray-800">🎉 Yay! 🎉</h2>
          <h3 className="text-2xl font-semibold mb-2 text-gray-700">{winningTeam.name}</h3>
        </CardContent>
      </Card>
      {/* Final Scoreboard */}
      <Card className="border-4 border-gray-200 shadow-xl">
        <CardContent className="p-6">
          <h3 className="text-2xl font-bold text-gray-800 mb-6 text-center">Final Scoreboard</h3>
          <div className="space-y-4">
            {sortedTeams.map((team, index) => {
              const colorClass = team.color === "blue" ? "bg-gray-50 border-gray-200" :
                               team.color === "green" ? "bg-gray-100 border-gray-300" :
                               team.color === "yellow" ? "bg-gray-50 border-gray-200" :
                               team.color === "red" ? "bg-gray-100 border-gray-300" :
                               team.color === "purple" ? "bg-gray-100 border-gray-300" :
                               "bg-gray-50 border-gray-200";
              
              const textClass = team.color === "blue" ? "text-gray-800" :
                               team.color === "green" ? "text-gray-800" :
                               team.color === "yellow" ? "text-gray-700" :
                               team.color === "red" ? "text-gray-800" :
                               team.color === "purple" ? "text-gray-800" :
                               "text-gray-800";

              const medalColor = index === 0 ? "bg-gray-700" :
                                index === 1 ? "bg-gray-500" :
                                index === 2 ? "bg-gray-600" :
                                "bg-gray-400";

              return (
                <div key={team.id} className={`flex items-center justify-between ${colorClass} p-4 rounded-xl border-2`}>
                  <div className="flex items-center">
                    <div className={`${medalColor} text-white w-10 h-10 rounded-full flex items-center justify-center font-bold text-lg mr-4`}>
                      {index + 1}
                    </div>
                    <div>
                      <h4 className={`font-bold ${textClass} text-lg`}>{team.name}</h4>
                      <p className={textClass.replace('800', '600')} style={{ fontSize: '0.875rem' }}>
                        {team.correctAnswers} correct
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center space-x-2">
                    {index === 0 && <Trophy className="text-gray-700" size={24} />}
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
          className="bg-gray-200 hover:bg-gray-300 text-gray-700 py-4 px-6 font-semibold transition-all duration-200"
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
          <Share className="mr-2 text-gray-700" size={16} />
          Share Results
        </Button>
      </div>
    </div>
  );
}
