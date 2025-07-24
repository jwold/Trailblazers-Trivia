import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent } from "@/components/ui/card";

import { Users, Plus, Minus } from "lucide-react";
import { useMutation } from "@tanstack/react-query";
import { apiRequest } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";
import { type Team, type GameSetup as GameSetupType } from "@shared/schema";
import { nanoid } from "nanoid";

interface GameSetupProps {
  onGameStart: (gameCode: string) => void;
}

const teamColors = [
  { name: "blue", class: "bg-blue-500", bgClass: "bg-blue-50", borderClass: "border-blue-200", textClass: "text-blue-800" },
  { name: "green", class: "bg-green-500", bgClass: "bg-green-50", borderClass: "border-green-200", textClass: "text-green-800" },
  { name: "yellow", class: "bg-yellow-500", bgClass: "bg-yellow-50", borderClass: "border-yellow-200", textClass: "text-yellow-800" },
  { name: "red", class: "bg-red-500", bgClass: "bg-red-50", borderClass: "border-red-200", textClass: "text-red-800" },
  { name: "purple", class: "bg-purple-500", bgClass: "bg-purple-50", borderClass: "border-purple-200", textClass: "text-purple-800" },
  { name: "orange", class: "bg-orange-500", bgClass: "bg-orange-50", borderClass: "border-orange-200", textClass: "text-orange-800" },
];

export default function GameSetup({ onGameStart }: GameSetupProps) {
  const [teams, setTeams] = useState<Team[]>([
    { id: nanoid(), name: "Blue Team", color: "blue", score: 0, correctAnswers: 0 },
    { id: nanoid(), name: "Green Team", color: "green", score: 0, correctAnswers: 0 },
  ]);
  const [targetScore, setTargetScore] = useState(10);

  const { toast } = useToast();

  const createGameMutation = useMutation({
    mutationFn: async (gameData: GameSetupType) => {
      const response = await apiRequest("POST", "/api/games", gameData);
      return response.json();
    },
    onSuccess: (data) => {
      toast({
        title: "Game Created!",
        description: `Game code: ${data.gameCode}`,
      });
      onGameStart(data.gameCode);
    },
    onError: () => {
      toast({
        title: "Error",
        description: "Failed to create game. Please try again.",
        variant: "destructive",
      });
    },
  });

  const updateTeamName = (teamId: string, name: string) => {
    setTeams(teams.map(team => 
      team.id === teamId ? { ...team, name } : team
    ));
  };



  const addTeam = () => {
    const usedColors = teams.map(team => team.color);
    const availableColor = teamColors.find(color => !usedColors.includes(color.name))?.name || "gray";
    const colorName = availableColor.charAt(0).toUpperCase() + availableColor.slice(1);
    
    setTeams([...teams, { 
      id: nanoid(), 
      name: `${colorName} Team`, 
      color: availableColor, 
      score: 0, 
      correctAnswers: 0 
    }]);
  };

  const removeTeam = (teamId: string) => {
    if (teams.length > 2) {
      setTeams(teams.filter(team => team.id !== teamId));
    }
  };

  const handleStartGame = () => {
    // Use teams as they are (default names are fine)
    if (teams.length < 2) {
      toast({
        title: "Error",
        description: "Please add at least 2 teams.",
        variant: "destructive",
      });
      return;
    }

    createGameMutation.mutate({
      teams: teams,
      targetScore,
    });
  };

  return (
    <div className="space-y-6">
      

      {/* Team Setup Card */}
      <Card className="border-4 border-brand-blue/20 shadow-xl">
        <CardContent className="p-6">
          

          <div className="space-y-4 mb-6">
            {teams.map((team, index) => {
              const colorConfig = teamColors.find(c => c.name === team.color) || teamColors[0];
              
              return (
                <div key={team.id} className={`${colorConfig.bgClass} p-4 rounded-xl border-2 ${colorConfig.borderClass}`}>
                  <Input
                    placeholder="Enter team name..."
                    value={team.name}
                    onChange={(e) => updateTeamName(team.id, e.target.value)}
                    className={`border-2 ${colorConfig.borderClass.replace('border-', 'border-')} focus:border-opacity-75 text-lg`}
                  />
                </div>
              );
            })}
          </div>

          {/* Add Team Button */}
          {teams.length < 6 && (
            <div className="text-center mb-6">
              <Button
                onClick={addTeam}
                variant="outline"
                className="bg-white border-2 border-dashed border-gray-300 hover:border-gray-400 hover:bg-gray-50 py-3 px-6 text-gray-600 hover:text-gray-800"
              >
                <Plus className="mr-2" size={20} />
                Add Team
              </Button>
            </div>
          )}

          {/* Game Settings */}
          <div className="bg-gray-50 p-4 rounded-xl mb-6">
            <div className="flex items-center justify-center gap-4">
              <Button
                onClick={() => setTargetScore(Math.max(10, targetScore - 5))}
                disabled={targetScore <= 10}
                variant="outline"
                size="lg"
                className="w-12 h-12 p-0 border-2 border-gray-300 hover:border-gray-400 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <Minus size={20} />
              </Button>
              
              <div className="bg-white border-2 border-gray-300 rounded-lg px-6 py-3 min-w-[120px] text-center">
                <div className="text-2xl font-bold text-gray-800">{targetScore}</div>
                <div className="text-sm text-gray-600">Points</div>
              </div>
              
              <Button
                onClick={() => setTargetScore(Math.min(50, targetScore + 5))}
                disabled={targetScore >= 50}
                variant="outline"
                size="lg"
                className="w-12 h-12 p-0 border-2 border-gray-300 hover:border-gray-400 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <Plus size={20} />
              </Button>
            </div>
          </div>

          {/* Start Game Button */}
          <Button
            onClick={handleStartGame}
            disabled={createGameMutation.isPending}
            className="w-full bg-gradient-to-r from-green-500 to-green-700 text-white py-6 px-8 text-2xl font-bold hover:from-green-600 hover:to-green-800 transition-all duration-200 transform hover:scale-105 shadow-xl border-4 border-green-300 ring-4 ring-green-200"
          >
            {createGameMutation.isPending ? (
              "Creating Game..."
            ) : (
              <>
                <svg className="mr-3 h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M8 5v14l11-7z"/>
                </svg>
                Start Bible Trivia Quest!
              </>
            )}
          </Button>
        </CardContent>
      </Card>

      
    </div>
  );
}
