import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";

import { Users, Plus, Minus, X, Check, BookOpen, Cat, Flag, Globe, MapPin, Gamepad2, Volume2, Info, HelpCircle, Mail } from "lucide-react";
import { useMutation } from "@tanstack/react-query";
import { apiRequest } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";
import { type Team, type GameSetup as GameSetupType } from "@shared/schema";
import { nanoid } from "nanoid";

type GameType = "Bible" | "Animals" | "US History" | "World History" | "Geography";

const gameTypeConfig = {
  "Bible": {
    icon: BookOpen,
    label: "Bible",
    description: "Test your biblical knowledge",
    bgColor: "bg-gradient-to-br from-gray-200 to-gray-300",
    borderColor: "border-gray-400",
    iconColor: "text-gray-700"
  },
  "Animals": {
    icon: Cat,
    label: "Animals",
    description: "Explore the animal kingdom",
    bgColor: "bg-gradient-to-br from-gray-200 to-gray-300",
    borderColor: "border-gray-400",
    iconColor: "text-gray-700"
  },
  "US History": {
    icon: Flag,
    label: "US History",
    description: "American historical events",
    bgColor: "bg-gradient-to-br from-gray-200 to-gray-300",
    borderColor: "border-gray-400",
    iconColor: "text-gray-700"
  },
  "World History": {
    icon: Globe,
    label: "World History",
    description: "Global historical knowledge",
    bgColor: "bg-gradient-to-br from-gray-200 to-gray-300",
    borderColor: "border-gray-400",
    iconColor: "text-gray-700"
  },
  "Geography": {
    icon: MapPin,
    label: "Geography",
    description: "World places and landmarks",
    bgColor: "bg-gradient-to-br from-gray-200 to-gray-300",
    borderColor: "border-gray-400",
    iconColor: "text-gray-700"
  }
};

interface GameSetupProps {
  onGameStart: (gameCode: string) => void;
  activeGameCode?: string;
  onResumeGame?: () => void;
}

const categoryNames = {
  "Bible": [
    "Israelites", "Levites", "Judeans", "Benjamites", "Ephraimites", "Shunammites",
    "Rechabites", "Ninevites", "Persians", "Cretans", "Romans", "Greeks", "Egyptians", "Philistines"
  ],
  "Animals": [
    "Lions", "Eagles", "Wolves", "Bears", "Tigers", "Hawks", "Foxes", "Dolphins",
    "Elephants", "Panthers", "Falcons", "Sharks", "Rhinos", "Jaguars"
  ],
  "US History": [
    "Patriots", "Colonists", "Pioneers", "Revolutionaries", "Federalists", "Yankees",
    "Rebels", "Union", "Minutemen", "Founding Fathers", "Pilgrims", "Cowboys", "Explorers", "Settlers"
  ],
  "World History": [
    "Spartans", "Vikings", "Samurai", "Knights", "Gladiators", "Crusaders",
    "Warriors", "Legions", "Conquerors", "Empire", "Dynasty", "Republic", "Pharaohs", "Emperors"
  ],
  "Geography": [
    "Explorers", "Navigators", "Mountaineers", "Voyagers", "Adventurers", "Trekkers",
    "Nomads", "Travelers", "Pioneers", "Compass", "Atlas", "Summit", "Valley", "Rivers"
  ]
};

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

export default function GameSetup({ onGameStart, activeGameCode, onResumeGame }: GameSetupProps) {
  const [selectedGameType, setSelectedGameType] = useState<GameType>("Bible");
  const [gameMode, setGameMode] = useState<"regular" | "shoutout">("regular");
  const [showRegularModal, setShowRegularModal] = useState(false);
  const [showShoutoutModal, setShowShoutoutModal] = useState(false);
  const [showHelpModal, setShowHelpModal] = useState(false);
  
  // Shuffle names for random assignment based on category
  const getShuffledNames = (category: GameType) => {
    const names = categoryNames[category];
    const shuffled = [...names];
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    return shuffled;
  };

  const [availableNames, setAvailableNames] = useState<string[]>(() => getShuffledNames(selectedGameType));
  const [teams, setTeams] = useState<Team[]>(() => {
    const initialNames = getShuffledNames(selectedGameType);
    return [
      { id: nanoid(), name: initialNames[0], color: "blue", score: 0, correctAnswers: 0 },
      { id: nanoid(), name: initialNames[1], color: "green", score: 0, correctAnswers: 0 },
    ];
  });
  // Track which team names have been manually customized by users
  const [customizedTeamNames, setCustomizedTeamNames] = useState<Set<string>>(new Set());
  const [targetScore, setTargetScore] = useState(10);

  const { toast } = useToast();

  const createGameMutation = useMutation({
    mutationFn: async (gameData: GameSetupType & { category: string }) => {
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
    // Mark this team as having a custom name
    setCustomizedTeamNames(prev => new Set(prev).add(teamId));
  };



  // Handle category change
  const handleCategoryChange = (newCategory: GameType) => {
    setSelectedGameType(newCategory);
    const newNames = getShuffledNames(newCategory);
    setAvailableNames(newNames);
    
    // Only update team names that haven't been manually customized
    setTeams(teams.map((team, index) => {
      // If this team has been customized, keep the custom name
      if (customizedTeamNames.has(team.id)) {
        return team;
      }
      // Otherwise, update with category-appropriate name
      return {
        ...team,
        name: index < newNames.length ? newNames[index] : `Team ${index + 1}`
      };
    }));
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
    if (teams.length > 1) {
      setTeams(teams.filter(team => team.id !== teamId));
      // Remove the team from customized names tracking
      setCustomizedTeamNames(prev => {
        const newSet = new Set(prev);
        newSet.delete(teamId);
        return newSet;
      });
    }
  };

  const handleStartGame = () => {
    // Use teams as they are (default names are fine)
    if (teams.length < 1) {
      toast({
        title: "Error",
        description: "Please add at least 1 team.",
        variant: "destructive",
      });
      return;
    }

    const categoryParam = selectedGameType.toLowerCase().replace(/\s+/g, '_');
    createGameMutation.mutate({
      teams: teams,
      targetScore,
      category: categoryParam,
      gameMode,
    });
  };

  return (
    <div className="space-y-6">
      {/* Combined Game Setup Card */}
      <Card className="border-4 border-gray-200">
        <CardContent className="p-6">
          {/* Header with Help Button */}
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-2xl font-bold text-gray-800">Bible Trivia Quest</h2>
            <Button
              variant="ghost"
              size="sm"
              className="text-gray-500 hover:text-gray-700"
              onClick={() => setShowHelpModal(true)}
            >
              <HelpCircle size={20} />
              <span className="ml-1">Help</span>
            </Button>
          </div>
          {/* Game Category Selection */}
          <h3 className="text-xl font-bold text-gray-800 mb-4 text-left">Choose your trivia category</h3>
          
          <div className="mb-8">
            <Select value={selectedGameType} onValueChange={handleCategoryChange}>
              <SelectTrigger className="w-full border-2 border-gray-300 focus:border-gray-600 py-6">
                <SelectValue>
                  <div className="flex items-center gap-3">
                    {selectedGameType && gameTypeConfig[selectedGameType] && (
                      <>
                        {(() => {
                          const IconComponent = gameTypeConfig[selectedGameType].icon;
                          return <IconComponent size={24} className={gameTypeConfig[selectedGameType].iconColor} />;
                        })()}
                        <span className="text-lg font-semibold">{gameTypeConfig[selectedGameType].label}</span>
                      </>
                    )}
                  </div>
                </SelectValue>
              </SelectTrigger>
              <SelectContent>
                {Object.entries(gameTypeConfig).map(([gameType, config]) => {
                  const IconComponent = config.icon;
                  return (
                    <SelectItem key={gameType} value={gameType}>
                      <div className="flex items-center gap-3 py-2">
                        <IconComponent size={20} className={config.iconColor} />
                        <span className="font-medium">{config.label}</span>
                      </div>
                    </SelectItem>
                  );
                })}
              </SelectContent>
            </Select>
          </div>

          {/* Game Mode Selection */}
          <div className="mb-8">
            <h3 className="text-xl font-bold text-gray-800 mb-4 text-left">Choose your game mode</h3>
            
            <div className="mb-8">
              <Select value={gameMode} onValueChange={(value: "regular" | "shoutout") => setGameMode(value)}>
                <SelectTrigger className="w-full border-2 border-gray-300 focus:border-gray-600 py-6">
                  <SelectValue>
                    <div className="flex items-center gap-3">
                      {gameMode === "regular" ? (
                        <>
                          <Gamepad2 size={24} className="text-gray-700" />
                          <span className="text-lg font-semibold">Regular</span>
                        </>
                      ) : (
                        <>
                          <Volume2 size={24} className="text-gray-700" />
                          <span className="text-lg font-semibold">Shoutout</span>
                        </>
                      )}
                    </div>
                  </SelectValue>
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="regular">
                    <div className="flex items-center gap-3">
                      <Gamepad2 size={20} className="text-gray-700" />
                      <span className="font-semibold">Regular</span>
                    </div>
                  </SelectItem>
                  <SelectItem value="shoutout">
                    <div className="flex items-center gap-3">
                      <Volume2 size={20} className="text-gray-700" />
                      <span className="font-semibold">Shoutout</span>
                    </div>
                  </SelectItem>
                </SelectContent>
              </Select>
            </div>
            
            {/* Modal Dialogs */}
            <Dialog open={showRegularModal} onOpenChange={setShowRegularModal}>
              <DialogContent className="max-w-md">
                <DialogHeader>
                  <DialogTitle className="flex items-center gap-2">
                    <Gamepad2 size={20} />
                    Regular Mode
                  </DialogTitle>
                </DialogHeader>
                <div className="space-y-3">
                  <p className="text-gray-700">
                    Teams take turns answering questions in an orderly fashion.
                  </p>
                  <div className="bg-blue-50 border border-blue-200 rounded-lg p-3">
                    <h4 className="font-semibold text-blue-800 mb-2">How it works:</h4>
                    <ul className="text-sm text-blue-700 space-y-1">
                      <li>• Teams answer one at a time</li>
                      <li>• Click "Correct" or "Wrong" to score</li>
                      <li>• Turn automatically advances to next team</li>
                      <li>• Perfect for classroom settings</li>
                    </ul>
                  </div>
                </div>
              </DialogContent>
            </Dialog>

            <Dialog open={showShoutoutModal} onOpenChange={setShowShoutoutModal}>
              <DialogContent className="max-w-md">
                <DialogHeader>
                  <DialogTitle className="flex items-center gap-2">
                    <Volume2 size={20} />
                    Shoutout Mode
                  </DialogTitle>
                </DialogHeader>
                <div className="space-y-3">
                  <p className="text-gray-700">
                    Fast-paced competition where all teams compete simultaneously!
                  </p>
                  <div className="bg-purple-50 border border-purple-200 rounded-lg p-3">
                    <h4 className="font-semibold text-purple-800 mb-2">How it works:</h4>
                    <ul className="text-sm text-purple-700 space-y-1">
                      <li>• All teams can answer at once</li>
                      <li>• Tap the team name who answered first</li>
                      <li>• Quick reactions and fast thinking</li>
                      <li>• Perfect for energetic groups</li>
                    </ul>
                  </div>
                </div>
              </DialogContent>
            </Dialog>

            {/* Help Modal */}
            <Dialog open={showHelpModal} onOpenChange={setShowHelpModal}>
              <DialogContent className="max-w-lg">
                <DialogHeader>
                  <DialogTitle className="flex items-center gap-2">
                    <HelpCircle size={20} />
                    Help & Support
                  </DialogTitle>
                </DialogHeader>
                <div className="space-y-3">
                  <div className="bg-blue-50 border border-blue-200 rounded-lg p-3">
                    <h4 className="font-semibold text-blue-800 mb-2">How to Play</h4>
                    <ul className="text-sm text-blue-700 space-y-1">
                      <li>• Pick category, mode, teams & target score</li>
                      <li>• Teams take turns answering questions</li>
                      <li>• First to target score wins!</li>
                    </ul>
                  </div>
                  
                  <div className="bg-gray-50 border border-gray-200 rounded-lg p-3">
                    <h4 className="font-semibold text-gray-800 mb-2">Game Modes</h4>
                    <div className="text-sm text-gray-700 space-y-1">
                      <div><strong>Regular:</strong> Teams take turns</div>
                      <div><strong>Shoutout:</strong> All teams compete at once</div>
                    </div>
                  </div>

                  <div className="bg-green-50 border border-green-200 rounded-lg p-3">
                    <div className="flex items-center gap-2 text-sm">
                      <Mail size={16} className="text-green-700" />
                      <span className="text-green-700">Contact: </span>
                      <a 
                        href="mailto:joshua@joshuawold.com" 
                        className="text-green-800 hover:text-green-900 font-medium"
                      >
                        joshua@joshuawold.com
                      </a>
                    </div>
                  </div>
                </div>
              </DialogContent>
            </Dialog>
          </div>

          {/* Team Setup Section */}
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-xl font-bold text-gray-800">Choose your team names</h3>
            {teams.length < 10 && (
              <Button
                onClick={addTeam}
                variant="ghost"
                className="text-gray-700 hover:text-gray-900 hover:bg-gray-100"
              >
                <Plus className="mr-1" size={20} />
                Team
              </Button>
            )}
          </div>

          <div className="space-y-4 mb-6">
            {teams.map((team, index) => {
              const colorConfig = teamColors.find(c => c.name === team.color) || teamColors[0];
              
              return (
                <div key={team.id} className="flex items-center gap-3">
                  <Input
                    placeholder="Enter team name..."
                    value={team.name}
                    onChange={(e) => updateTeamName(team.id, e.target.value)}
                    className={`border-2 ${colorConfig.borderClass.replace('border-', 'border-')} focus:border-opacity-75 text-lg flex-1`}
                  />
                  {index >= 1 && teams.length > 1 && (
                    <Button
                      onClick={() => removeTeam(team.id)}
                      size="sm"
                      className="w-8 h-8 p-0 bg-gray-200 hover:bg-gray-300 text-gray-700 flex-shrink-0"
                    >
                      <X size={16} className="text-gray-700" />
                    </Button>
                  )}
                </div>
              );
            })}
          </div>



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

          {/* Resume Game Button - Only show if there's an active game */}
          {activeGameCode && onResumeGame && (
            <Button
              onClick={onResumeGame}
              className="w-full bg-gradient-to-r from-gray-500 to-gray-600 text-white py-6 px-8 text-xl font-semibold hover:from-gray-600 hover:to-gray-700 transition-all duration-200 border-4 border-gray-400 mb-4"
            >
              Resume Game ({activeGameCode})
            </Button>
          )}

          {/* Start Game Button */}
          <Button
            onClick={handleStartGame}
            disabled={createGameMutation.isPending}
            className="w-full bg-gradient-to-r from-blue-600 to-blue-800 text-white py-6 px-8 font-bold hover:from-blue-700 hover:to-blue-900 transition-all duration-200 border-4 border-blue-400 text-[30px] pt-[32px] pb-[32px]"
          >
            {createGameMutation.isPending ? (
              "Creating Game..."
            ) : (
              "Start New Game!"
            )}
          </Button>
        </CardContent>
      </Card>
    </div>
  );
}
