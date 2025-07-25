import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent } from "@/components/ui/card";

import { Users, Plus, Minus, X } from "lucide-react";
import { useMutation } from "@tanstack/react-query";
import { apiRequest } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";
import { type Team, type GameSetup as GameSetupType } from "@shared/schema";
import { nanoid } from "nanoid";

interface GameSetupProps {
  onGameStart: (gameCode: string) => void;
}

const biblicalNames = [
  "Israelites", "Levites", "Judeans", "Benjamites", "Ephraimites", "Shunammites",
  "Rechabites", "Ninevites", "Persians", "Cretans", "Romans", "Greeks", "Egyptians", "Philistines"
];

const teamColors = [
  { name: "blue", class: "bg-gray-500", bgClass: "bg-gray-100", borderClass: "border-gray-300", textClass: "text-gray-800" },
  { name: "green", class: "bg-gray-600", bgClass: "bg-gray-100", borderClass: "border-gray-300", textClass: "text-gray-800" },
  { name: "yellow", class: "bg-gray-400", bgClass: "bg-gray-100", borderClass: "border-gray-300", textClass: "text-gray-800" },
  { name: "red", class: "bg-gray-700", bgClass: "bg-gray-100", borderClass: "border-gray-300", textClass: "text-gray-800" },
  { name: "purple", class: "bg-gray-800", bgClass: "bg-gray-100", borderClass: "border-gray-300", textClass: "text-gray-800" },
  { name: "orange", class: "bg-gray-600", bgClass: "bg-gray-100", borderClass: "border-gray-300", textClass: "text-gray-800" },
  { name: "teal", class: "bg-gray-500", bgClass: "bg-gray-100", borderClass: "border-gray-300", textClass: "text-gray-800" },
  { name: "pink", class: "bg-gray-400", bgClass: "bg-gray-100", borderClass: "border-gray-300", textClass: "text-gray-800" },
  { name: "indigo", class: "bg-gray-700", bgClass: "bg-gray-100", borderClass: "border-gray-300", textClass: "text-gray-800" },
  { name: "cyan", class: "bg-gray-600", bgClass: "bg-gray-100", borderClass: "border-gray-300", textClass: "text-gray-800" },
];

export default function GameSetup({ onGameStart }: GameSetupProps) {
  // Shuffle biblical names for random assignment
  const getShuffledNames = () => {
    const shuffled = [...biblicalNames];
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    return shuffled;
  };

  const [availableNames] = useState<string[]>(getShuffledNames());
  const [teams, setTeams] = useState<Team[]>([
    { id: nanoid(), name: availableNames[0], color: "blue", score: 0, correctAnswers: 0 },
    { id: nanoid(), name: availableNames[1], color: "green", score: 0, correctAnswers: 0 },
  ]);
  const [targetScore, setTargetScore] = useState(10);

  const { toast } = useToast();

  const createGameMutation = useMutation({
    mutationFn: async (gameData: GameSetupType) => {
      const response = await apiRequest("POST", "/api/games", gameData);
      return response.json();
    },
    onSuccess: (data) => {
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
    const nextNameIndex = teams.length;
    const teamName = nextNameIndex < availableNames.length ? availableNames[nextNameIndex] : `Team ${teams.length + 1}`;
    
    setTeams([...teams, { 
      id: nanoid(), 
      name: teamName, 
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
      <Card className="border-4 border-gray-200 shadow-xl">
        <CardContent className="p-6">
          

          <div className="space-y-4 mb-6">
            {teams.map((team, index) => {
              const colorConfig = teamColors.find(c => c.name === team.color) || teamColors[0];
              
              return (
                <div key={team.id} className={`${colorConfig.bgClass} p-4 rounded-xl border-2 ${colorConfig.borderClass}`}>
                  <div className="flex items-center gap-3">
                    {index >= 2 && (
                      <Button
                        onClick={() => removeTeam(team.id)}
                        size="sm"
                        className="w-8 h-8 p-0 bg-gray-200 hover:bg-gray-300 text-gray-700 flex-shrink-0"
                      >
                        <X size={16} className="text-gray-700" />
                      </Button>
                    )}
                    <Input
                      placeholder="Enter team name..."
                      value={team.name}
                      onChange={(e) => updateTeamName(team.id, e.target.value)}
                      className={`border-2 ${colorConfig.borderClass.replace('border-', 'border-')} focus:border-opacity-75 text-lg flex-1`}
                    />
                  </div>
                </div>
              );
            })}
          </div>

          {/* Add Team Button */}
          {teams.length < 10 && (
            <div className="text-center mb-6">
              <Button
                onClick={addTeam}
                className="bg-gray-200 hover:bg-gray-300 text-gray-700 border-2 border-dashed border-gray-400 py-3 px-6"
              >
                <Plus className="mr-2 text-gray-700" size={20} />
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
                size="lg"
                className="w-12 h-12 p-0 bg-gray-200 hover:bg-gray-300 text-gray-700 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <Minus size={20} className="text-gray-700" />
              </Button>
              
              <div className="bg-white border-2 border-gray-300 rounded-lg px-6 py-3 min-w-[120px] text-center">
                <div className="text-2xl font-bold text-gray-800">{targetScore}</div>
                <div className="text-sm text-gray-600">Points</div>
              </div>
              
              <Button
                onClick={() => setTargetScore(Math.min(50, targetScore + 5))}
                disabled={targetScore >= 50}
                size="lg"
                className="w-12 h-12 p-0 bg-gray-200 hover:bg-gray-300 text-gray-700 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <Plus size={20} className="text-gray-700" />
              </Button>
            </div>
          </div>

          {/* Start Game Button */}
          <Button
            onClick={handleStartGame}
            disabled={createGameMutation.isPending}
            className="w-full bg-gradient-to-r from-gray-600 to-gray-800 text-white py-6 px-8 text-2xl font-bold hover:from-gray-700 hover:to-gray-900 transition-all duration-200 transform hover:scale-105 shadow-xl border-4 border-gray-400 ring-4 ring-gray-300"
          >
            {createGameMutation.isPending ? (
              "Creating Game..."
            ) : (
              "Start"
            )}
          </Button>
        </CardContent>
      </Card>

      
    </div>
  );
}
