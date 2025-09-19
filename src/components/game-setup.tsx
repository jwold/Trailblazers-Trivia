import { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";

import { BookOpen, Cat, Flag, Globe, MapPin, Gamepad2, Volume2, Plus, Minus, Check, Navigation, Crown } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { staticGameService, type Team, type GameSetup as GameSetupType } from "@/services/static-game-service";
import Paywall from "./paywall";

function nanoid() {
  return Math.random().toString(36).substring(2, 11);
}

type GameType = "Bible" | "Animals" | "US History" | "World History" | "Geography";

const gameTypeConfig = {
  "Bible": {
    icon: BookOpen,
    label: "Bible",
    description: "Test your biblical knowledge",
    iconColor: "text-gray-700",
    isPremium: false
  },
  "Animals": {
    icon: Cat,
    label: "Animals",
    description: "Explore the animal kingdom",
    iconColor: "text-gray-700",
    isPremium: true
  },
  "US History": {
    icon: Flag,
    label: "US History",
    description: "American historical events",
    iconColor: "text-gray-700",
    isPremium: true
  },
  "World History": {
    icon: Globe,
    label: "World History",
    description: "Global historical knowledge",
    iconColor: "text-gray-700",
    isPremium: true
  },
  "Geography": {
    icon: Navigation,
    label: "Geography",
    description: "World places and landmarks",
    iconColor: "text-gray-700",
    isPremium: true
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
  const [showPaywall, setShowPaywall] = useState(false);
  const [isPremiumUnlocked, setIsPremiumUnlocked] = useState(false);
  const [gameMode, setGameMode] = useState<"regular" | "shoutout">("regular");
  const [showRegularModal, setShowRegularModal] = useState(false);
  const [showShoutoutModal, setShowShoutoutModal] = useState(false);
  
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
  const [targetScore, setTargetScore] = useState(10);

  const { toast } = useToast();
  const [isCreating, setIsCreating] = useState(false);

  useEffect(() => {
    // Check if premium is unlocked
    const unlocked = localStorage.getItem('premium_unlocked') === 'true';
    setIsPremiumUnlocked(unlocked);
  }, []);




  // Handle category change
  const handleCategoryChange = (newCategory: GameType) => {
    const config = gameTypeConfig[newCategory];

    // Check if it's premium and not unlocked
    if (config.isPremium && !isPremiumUnlocked) {
      setShowPaywall(true);
      return;
    }

    setSelectedGameType(newCategory);
    const newNames = getShuffledNames(newCategory);
    setAvailableNames(newNames);

    // Update team names with new category names
    setTeams(teams.map((team, index) => {
      return {
        ...team,
        name: index < newNames.length ? newNames[index] : `Team ${index + 1}`
      };
    }));
  };

  const handleUnlock = () => {
    setIsPremiumUnlocked(true);
    toast({
      title: "Premium Unlocked!",
      description: "You now have access to all categories.",
    });
  };


  const handleStartGame = async () => {
    // Use teams as they are (default names are fine)
    if (teams.length < 2) {
      toast({
        title: "Error",
        description: "Please add at least 2 teams.",
        variant: "destructive",
      });
      return;
    }

    const categoryParam = selectedGameType.toLowerCase().replace(/\s+/g, '_');
    
    setIsCreating(true);
    try {
      const result = await staticGameService.createGame({
        teams: teams,
        targetScore,
        category: categoryParam,
        gameMode,
      });
      onGameStart(result.gameCode);
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to create game. Please try again.",
        variant: "destructive",
      });
    } finally {
      setIsCreating(false);
    }
  };

  return (
    <div className="space-y-6 bg-white rounded-2xl p-6">
      {/* Game Category List */}
      <div className="space-y-3">
        {Object.entries(gameTypeConfig).map(([gameType, config]) => {
          const IconComponent = config.icon;
          const isSelected = selectedGameType === gameType;
          const isLocked = config.isPremium && !isPremiumUnlocked;

          return (
            <button
              key={gameType}
              onClick={() => handleCategoryChange(gameType as GameType)}
              className={`w-full p-4 rounded-2xl border transition-all flex items-center justify-between relative ${
                isSelected
                  ? 'border-blue-500 bg-white'
                  : isLocked
                  ? 'border-gray-200 bg-gray-50 hover:border-gray-300'
                  : 'border-gray-200 bg-white hover:border-gray-300'
              }`}
            >
              <div className="flex items-center gap-3">
                <IconComponent size={24} className={isLocked ? "text-gray-400" : "text-gray-700"} />
                <div className="text-left">
                  <span className={`font-medium text-lg ${isLocked ? 'text-gray-500' : 'text-gray-900'}`}>
                    {config.label}
                  </span>
                </div>
              </div>
              <div className="flex items-center gap-2">
                {isLocked && (
                  <Crown size={18} className="text-yellow-500" />
                )}
                {isSelected && !isLocked && (
                  <div className="w-6 h-6 bg-blue-500 rounded-full flex items-center justify-center">
                    <Check size={16} className="text-white" />
                  </div>
                )}
              </div>
            </button>
          );
        })}
      </div>

          {/* Game Mode Selection */}
          <div className="mb-8 hidden">
            
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

          </div>




          {/* Game Settings */}
          <div className="bg-gray-50 p-4 rounded-xl mb-6 hidden">
            <div className="flex items-center justify-center gap-4">
              <Button
                onClick={() => setTargetScore(Math.max(10, targetScore - 5))}
                disabled={targetScore <= 10}
                size="lg"
                className="w-12 h-12 p-0 bg-gray-200 hover:bg-gray-300 text-gray-700 disabled:opacity-50 disabled:cursor-not-allowed">
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
                className="w-12 h-12 p-0 bg-gray-200 hover:bg-gray-300 text-gray-700 disabled:opacity-50 disabled:cursor-not-allowed">
                <Plus size={20} className="text-gray-700" />
              </Button>
            </div>
          </div>


      {/* Start Game Button */}
      <Button
        onClick={handleStartGame}
        disabled={isCreating}
        className="w-full bg-blue-500 hover:bg-blue-600 text-white py-4 px-6 font-semibold rounded-2xl text-lg transition-all duration-200 shadow-sm"
      >
        {isCreating ? (
          "Creating Game..."
        ) : (
          "Start New Game!"
        )}
      </Button>

      {/* Paywall Modal */}
      <Paywall
        isOpen={showPaywall}
        onClose={() => setShowPaywall(false)}
        onUnlock={handleUnlock}
      />
    </div>
  );
}
