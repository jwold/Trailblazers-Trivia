import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { useQuery } from "@tanstack/react-query";
import { Crown, Trophy, Plus, Share } from "lucide-react";
import { type Team } from "@shared/schema";
import { createConfetti } from "../lib/game-logic";
import { useEffect } from "react";

interface VictoryScreenProps {
  gameCode: string;
  onNewGame: () => void;
}

export default function VictoryScreen({ gameCode, onNewGame }: VictoryScreenProps) {
  const { data: gameSession, isLoading } = useQuery({
    queryKey: ["/api/games", gameCode],
  });

  useEffect(() => {
    // Create celebration effect on mount
    createConfetti();
    const interval = setInterval(createConfetti, 2000);
    return () => clearInterval(interval);
  }, []);

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
      <Card className="bg-gradient-to-r from-yellow-400 via-yellow-500 to-yellow-600 text-white border-4 border-yellow-200 shadow-xl">
        <CardContent className="p-8 text-center">
          <div className="bounce-slow mb-4">
            <Crown className="mx-auto" size={64} />
          </div>
          <h2 className="text-4xl font-bold mb-4">🎉 Congratulations! 🎉</h2>
          <h3 className="text-2xl font-semibold mb-2">{winningTeam.name}</h3>
        </CardContent>
      </Card>

      {/* Final Scoreboard */}
      <Card className="border-4 border-brand-blue/20 shadow-xl">
        <CardContent className="p-6">
          <h3 className="text-2xl font-bold text-gray-800 mb-6 text-center">Final Scoreboard</h3>
          <div className="space-y-4">
            {sortedTeams.map((team, index) => {
              const colorClass = team.color === "blue" ? "bg-blue-50 border-blue-200" :
                               team.color === "green" ? "bg-green-50 border-green-200" :
                               team.color === "yellow" ? "bg-yellow-50 border-yellow-200" :
                               team.color === "red" ? "bg-red-50 border-red-200" :
                               team.color === "purple" ? "bg-purple-50 border-purple-200" :
                               "bg-orange-50 border-orange-200";
              
              const textClass = team.color === "blue" ? "text-blue-800" :
                               team.color === "green" ? "text-green-800" :
                               team.color === "yellow" ? "text-yellow-800" :
                               team.color === "red" ? "text-red-800" :
                               team.color === "purple" ? "text-purple-800" :
                               "text-orange-800";

              const medalColor = index === 0 ? "bg-yellow-500" :
                                index === 1 ? "bg-gray-400" :
                                index === 2 ? "bg-orange-600" :
                                "bg-gray-300";

              return (
                <div key={team.id} className={`flex items-center justify-between ${colorClass} p-4 rounded-xl border-2`}>
                  <div className="flex items-center">
                    <div className={`${medalColor} text-white w-10 h-10 rounded-full flex items-center justify-center font-bold text-lg mr-4`}>
                      {index + 1}
                    </div>
                    <div>
                      <h4 className={`font-bold ${textClass} text-lg`}>{team.name}</h4>
                      <p className={textClass.replace('800', '600')} style={{ fontSize: '0.875rem' }}>
                        {team.correctAnswers} correct answers
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center space-x-2">
                    {index === 0 && <Trophy className="text-yellow-500" size={24} />}
                    <div className={`text-3xl font-bold ${textClass}`}>{team.score}</div>
                  </div>
                </div>
              );
            })}
          </div>
        </CardContent>
      </Card>

      {/* Game Stats */}
      <Card className="border-4 border-brand-green/20 shadow-xl">
        <CardContent className="p-6">
          <h3 className="text-xl font-bold text-gray-800 mb-4">Game Summary</h3>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div className="text-center p-4 bg-blue-50 rounded-xl">
              <div className="text-2xl font-bold text-blue-600">{totalQuestions}</div>
              <p className="text-blue-800 font-medium">Questions Asked</p>
            </div>
            <div className="text-center p-4 bg-green-50 rounded-xl">
              <div className="text-2xl font-bold text-green-600">{totalCorrectAnswers}</div>
              <p className="text-green-800 font-medium">Correct Answers</p>
            </div>
            <div className="text-center p-4 bg-yellow-50 rounded-xl">
              <div className="text-2xl font-bold text-yellow-600">{winningTeam.score}</div>
              <p className="text-yellow-800 font-medium">Winning Score</p>
            </div>
            <div className="text-center p-4 bg-purple-50 rounded-xl">
              <div className="text-2xl font-bold text-purple-600">{gameSession.targetScore}</div>
              <p className="text-purple-800 font-medium">Target Score</p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Action Buttons */}
      <div className="flex justify-center">
        <Button
          onClick={onNewGame}
          className="bg-gradient-to-r from-blue-500 to-blue-600 text-white py-6 px-8 text-xl font-bold hover:from-blue-600 hover:to-blue-700 transition-all duration-200 transform hover:scale-105 shadow-lg border-4 border-blue-200"
        >
          <Plus className="mr-3" size={24} />
          New Game
        </Button>
      </div>

      {/* Share Results */}
      <Card className="bg-gradient-to-r from-purple-500 to-purple-600 text-white border-4 border-purple-200 shadow-xl">
        <CardContent className="p-6 text-center">
          <h4 className="text-xl font-bold mb-4">Share Your Victory!</h4>
          <p className="mb-4 opacity-90">Tell your friends about your Bible knowledge!</p>
          <Button 
            className="bg-white text-purple-600 hover:bg-purple-50 transition-colors"
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
        </CardContent>
      </Card>
    </div>
  );
}
