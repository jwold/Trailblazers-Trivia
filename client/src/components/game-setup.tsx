import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Users, Lightbulb, Plus } from "lucide-react";
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
    { id: nanoid(), name: "", color: "blue", score: 0, correctAnswers: 0 },
    { id: nanoid(), name: "", color: "green", score: 0, correctAnswers: 0 },
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
    
    setTeams([...teams, { 
      id: nanoid(), 
      name: "", 
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
    const validTeams = teams.filter(team => team.name.trim() !== "");
    
    if (validTeams.length < 2) {
      toast({
        title: "Error",
        description: "Please add at least 2 teams with names.",
        variant: "destructive",
      });
      return;
    }

    createGameMutation.mutate({
      teams: validTeams,
      targetScore,
    });
  };

  return (
    <div className="space-y-6">
      

      {/* Team Setup Card */}
      <Card className="border-4 border-brand-blue/20 shadow-xl">
        <CardContent className="p-6">
          <div className="flex items-center mb-6">
            <div className="bg-brand-blue p-3 rounded-full mr-4">
              <Users className="text-white" size={20} />
            </div>
            <h3 className="text-2xl font-bold text-gray-800">Set Up Teams</h3>
          </div>

          <div className="space-y-4 mb-6">
            {teams.map((team, index) => {
              const colorConfig = teamColors.find(c => c.name === team.color) || teamColors[0];
              
              return (
                <div key={team.id} className={`${colorConfig.bgClass} p-4 rounded-xl border-2 ${colorConfig.borderClass}`}>
                  <div className="flex items-center justify-between mb-3">
                    <label className={`text-lg font-semibold ${colorConfig.textClass}`}>
                      Team {index + 1}
                    </label>
                    {teams.length > 2 && (
                      <Button 
                        variant="ghost" 
                        size="sm"
                        onClick={() => removeTeam(team.id)}
                        className="text-red-600 hover:text-red-800"
                      >
                        ×
                      </Button>
                    )}
                  </div>
                  <Input
                    placeholder="Enter team name..."
                    value={team.name}
                    onChange={(e) => updateTeamName(team.id, e.target.value)}
                    className={`border-2 ${colorConfig.borderClass.replace('border-', 'border-')} focus:border-opacity-75 text-lg`}
                  />
                </div>
              );
            })}

            {teams.length < 6 && (
              <Button
                onClick={addTeam}
                className="w-full bg-gradient-to-r from-purple-400 to-purple-600 text-white py-4 px-6 text-lg font-semibold hover:from-purple-500 hover:to-purple-700 transition-all duration-200 transform hover:scale-105 border-4 border-purple-200"
              >
                <Plus className="mr-2" size={20} />
                Add Another Team
              </Button>
            )}
          </div>

          {/* Game Settings */}
          <div className="bg-gray-50 p-4 rounded-xl mb-6">
            <div className="max-w-xs">
              
              <Select value={targetScore.toString()} onValueChange={(value) => setTargetScore(parseInt(value))}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="10">10 Points</SelectItem>
                  <SelectItem value="15">15 Points</SelectItem>
                  <SelectItem value="20">20 Points</SelectItem>
                </SelectContent>
              </Select>
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

      {/* How to Play Card */}
      <Card className="border-4 border-brand-yellow/20 shadow-xl">
        <CardContent className="p-6">
          <div className="flex items-center mb-4">
            <div className="bg-brand-yellow p-3 rounded-full mr-4">
              <Lightbulb className="text-white" size={20} />
            </div>
            <h3 className="text-xl font-bold text-gray-800">How to Play</h3>
          </div>
          <div className="grid md:grid-cols-3 gap-4">
            <div className="text-center p-4 bg-blue-50 rounded-xl">
              <div className="bg-blue-500 w-12 h-12 rounded-full flex items-center justify-center mx-auto mb-3">
                <span className="text-white font-bold text-lg">1</span>
              </div>
              <h4 className="font-semibold text-blue-800 mb-2">Choose Difficulty</h4>
              <p className="text-sm text-blue-600">Easy = 1 point<br/>Medium = 2 points<br/>Hard = 3 points</p>
            </div>
            <div className="text-center p-4 bg-green-50 rounded-xl">
              <div className="bg-green-500 w-12 h-12 rounded-full flex items-center justify-center mx-auto mb-3">
                <span className="text-white font-bold text-lg">2</span>
              </div>
              <h4 className="font-semibold text-green-800 mb-2">Answer Questions</h4>
              <p className="text-sm text-green-600">Work as a team to answer Bible questions and earn points!</p>
            </div>
            <div className="text-center p-4 bg-yellow-50 rounded-xl">
              <div className="bg-yellow-500 w-12 h-12 rounded-full flex items-center justify-center mx-auto mb-3">
                <span className="text-white font-bold text-lg">3</span>
              </div>
              <h4 className="font-semibold text-yellow-800 mb-2">First to Target Wins!</h4>
              <p className="text-sm text-yellow-600">Race to reach the target score and celebrate your victory!</p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
