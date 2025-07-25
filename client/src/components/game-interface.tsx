import { useState, useEffect, useRef } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { Input } from "@/components/ui/input";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiRequest } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";
import { Users, Gamepad2, Check, X, SkipForward, Square, History, Edit2, Eye, EyeOff, Book, Globe, MapPin, Heart, Landmark } from "lucide-react";
import { type Team, type TriviaQuestion, type ClientGameSession, type QuestionHistoryEntry } from "@shared/schema";
// import { createConfetti, createEncouragement } from "../lib/game-logic";

interface GameInterfaceProps {
  gameCode: string;
  onGameEnd: () => void;
}

type GamePhase = "difficulty-selection" | "question-display";
type Difficulty = "Easy" | "Hard";
type GameType = "Bible" | "Animals" | "US History" | "World History" | "Geography";

const difficultyConfig = {
  Easy: { points: 1, bibleAssistPoints: 0.5, color: "gray", bgColor: "bg-gray-600", hoverColor: "hover:bg-gray-700" },
  Hard: { points: 3, bibleAssistPoints: 1, color: "gray", bgColor: "bg-gray-800", hoverColor: "hover:bg-gray-900" },
};

const gameTypeConfig = {
  Bible: {
    label: "Bible",
    icon: Book,
    description: "Biblical knowledge and stories",
    bgColor: "bg-gradient-to-br from-blue-100 to-purple-100",
    borderColor: "border-blue-200",
    iconColor: "text-blue-600"
  },
  Animals: {
    label: "Animals",
    icon: Heart,
    description: "Wildlife and nature facts",
    bgColor: "bg-gradient-to-br from-green-100 to-emerald-100",
    borderColor: "border-green-200",
    iconColor: "text-green-600"
  },
  "US History": {
    label: "US History",
    icon: Landmark,
    description: "American historical events",
    bgColor: "bg-gradient-to-br from-red-100 to-orange-100",
    borderColor: "border-red-200",
    iconColor: "text-red-600"
  },
  "World History": {
    label: "World History",
    icon: Globe,
    description: "Global historical events",
    bgColor: "bg-gradient-to-br from-yellow-100 to-amber-100",
    borderColor: "border-yellow-200",
    iconColor: "text-yellow-600"
  },
  Geography: {
    label: "Geography",
    icon: MapPin,
    description: "Countries, capitals & landmarks",
    bgColor: "bg-gradient-to-br from-cyan-100 to-blue-100",
    borderColor: "border-cyan-200",
    iconColor: "text-cyan-600"
  }
};

export default function GameInterface({ gameCode, onGameEnd }: GameInterfaceProps) {
  const [gamePhase, setGamePhase] = useState<GamePhase>("difficulty-selection");
  const [currentQuestion, setCurrentQuestion] = useState<TriviaQuestion | null>(null);
  const [selectedDifficulty, setSelectedDifficulty] = useState<Difficulty | null>(null);
  const [showHistory, setShowHistory] = useState(false);
  const [questionNumber, setQuestionNumber] = useState(1);
  const [questionAnswered, setQuestionAnswered] = useState(false);
  const [editingTeamId, setEditingTeamId] = useState<string | null>(null);
  const [editingTeamName, setEditingTeamName] = useState<string>("");
  const [teamAnimations, setTeamAnimations] = useState<Record<string, 'correct' | 'incorrect' | null>>({});
  const [teamsExpanded, setTeamsExpanded] = useState(false);
  const [teamTransitioning, setTeamTransitioning] = useState(false);
  const [answerVisible, setAnswerVisible] = useState(false);
  const [selectedGameType, setSelectedGameType] = useState<GameType>("Bible");
  const { toast } = useToast();
  const queryClient = useQueryClient();
  const prevTeamIndexRef = useRef<number | null>(null);

  const { data: gameSession, isLoading } = useQuery<ClientGameSession>({
    queryKey: ["/api/games", gameCode],
    refetchInterval: 1000,
  });

  // Handle team transitions with fade effect
  useEffect(() => {
    if (!gameSession || teamsExpanded) return;
    
    const currentTeamIndex = gameSession.currentTeamIndex;
    
    if (prevTeamIndexRef.current !== null && 
        prevTeamIndexRef.current !== currentTeamIndex && 
        currentTeamIndex !== null) {
      
      // Start fade-out transition
      setTeamTransitioning(true);
      
      // After fade-out completes, fade in the new team
      setTimeout(() => {
        setTeamTransitioning(false);
      }, 500); // Shorter duration to reduce jumping
    }
    
    prevTeamIndexRef.current = currentTeamIndex;
  }, [gameSession?.currentTeamIndex, teamsExpanded]);

  const fetchQuestionMutation = useMutation({
    mutationFn: async (difficulty: string) => {
      const categoryParam = selectedGameType.toLowerCase().replace(/\s+/g, '_');
      const response = await apiRequest("GET", `/api/games/${gameCode}/question/${difficulty}?category=${categoryParam}`);
      return response.json();
    },
    onSuccess: (question: TriviaQuestion) => {
      setCurrentQuestion(question);
      setGamePhase("question-display");
      setQuestionAnswered(false);
      setAnswerVisible(false);
    },
    onError: () => {
      toast({
        title: "No More Questions",
        description: "No more questions available for this difficulty.",
        variant: "destructive",
      });
    },
  });

  const updateGameMutation = useMutation({
    mutationFn: async (updates: Partial<ClientGameSession>) => {
      const response = await apiRequest("PUT", `/api/games/${gameCode}`, updates);
      return response.json();
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/games", gameCode] });
    },
  });



  const selectDifficulty = (difficulty: Difficulty) => {
    setSelectedDifficulty(difficulty);
    fetchQuestionMutation.mutate(difficulty);
  };

  const markCorrect = (usedBibleAssist = false) => {
    if (!gameSession || !selectedDifficulty || !currentQuestion || gameSession.currentTeamIndex === null) return;
    
    const teams: Team[] = [...gameSession.teams];
    const currentTeamIndex = gameSession.currentTeamIndex;
    const currentTeam = teams[currentTeamIndex];
    
    // Trigger correct answer animation
    setTeamAnimations(prev => ({ ...prev, [currentTeam.id]: 'correct' }));
    setTimeout(() => {
      setTeamAnimations(prev => ({ ...prev, [currentTeam.id]: null }));
    }, 2000);
    
    // createConfetti();
    
    const points = usedBibleAssist 
      ? difficultyConfig[selectedDifficulty].bibleAssistPoints 
      : difficultyConfig[selectedDifficulty].points;
    
    // Update current team's score
    teams[currentTeamIndex].score += points;
    teams[currentTeamIndex].correctAnswers += 1;
    
    // Add question to history
    const questionHistory: number[] = [...gameSession.questionHistory, currentQuestion.id];
    
    // Add detailed history entry
    const detailedHistory: QuestionHistoryEntry[] = [...gameSession.detailedHistory];
    detailedHistory.push({
      questionId: currentQuestion.id,
      teamId: currentTeam.id,
      teamName: currentTeam.name,
      difficulty: selectedDifficulty,
      question: currentQuestion.question,
      answer: currentQuestion.answer,
      reference: currentQuestion.reference,
      points: points,
      wasCorrect: true,
      timestamp: Date.now(),
    });
    
    // Check for winner
    const hasWinner = teams[currentTeamIndex].score >= (gameSession.targetScore || 10);
    
    // Move to next team after answering
    const nextTeamIndex = (gameSession.currentTeamIndex + 1) % gameSession.teams.length;
    
    updateGameMutation.mutate({
      teams: teams,
      questionHistory: questionHistory,
      detailedHistory: detailedHistory,
      currentTeamIndex: nextTeamIndex,
      gamePhase: hasWinner ? "victory" : "playing",
    });
    
    if (hasWinner) {
      setTimeout(() => onGameEnd(), 2000);
    }
    
    setQuestionAnswered(true);
  };

  const markIncorrect = () => {
    if (!gameSession || !selectedDifficulty || !currentQuestion || gameSession.currentTeamIndex === null) return;
    
    const currentTeam = gameSession.teams[gameSession.currentTeamIndex];
    
    // Trigger incorrect answer animation
    setTeamAnimations(prev => ({ ...prev, [currentTeam.id]: 'incorrect' }));
    setTimeout(() => {
      setTeamAnimations(prev => ({ ...prev, [currentTeam.id]: null }));
    }, 1000);
    
    // Add detailed history entry for incorrect answer
    const detailedHistory: QuestionHistoryEntry[] = [...gameSession.detailedHistory];
    detailedHistory.push({
      questionId: currentQuestion.id,
      teamId: currentTeam.id,
      teamName: currentTeam.name,
      difficulty: selectedDifficulty,
      question: currentQuestion.question,
      answer: currentQuestion.answer,
      reference: currentQuestion.reference,
      points: 0,
      wasCorrect: false,
      timestamp: Date.now(),
    });
    
    // Add question to history to prevent reappearance
    const questionHistory: number[] = [...gameSession.questionHistory, currentQuestion.id];
    
    // Move to next team
    const nextTeamIndex = (gameSession.currentTeamIndex + 1) % gameSession.teams.length;
    
    updateGameMutation.mutate({
      currentTeamIndex: nextTeamIndex,
      questionHistory: questionHistory,
      detailedHistory: detailedHistory,
    });
    
    setQuestionAnswered(true);
  };



  const nextQuestion = () => {
    if (!gameSession || !currentQuestion) return;
    
    // Team rotation is already handled in markCorrect/markIncorrect
    // Just reset the question state
    setQuestionNumber(prev => prev + 1);
    setGamePhase("difficulty-selection");
    setCurrentQuestion(null);
    setSelectedDifficulty(null);
    setQuestionAnswered(false);
    setAnswerVisible(false);
    // Clear any remaining team animations
    setTeamAnimations({});
  };

  const skipQuestion = () => {
    if (!gameSession || !currentQuestion) return;
    
    // Add skipped question to history to prevent it from appearing again
    const questionHistory: number[] = [...gameSession.questionHistory, currentQuestion.id];
    
    updateGameMutation.mutate({
      questionHistory: questionHistory,
    });
    
    nextQuestion();
  };

  const endGame = () => {
    updateGameMutation.mutate({
      gamePhase: "victory",
    });
    onGameEnd();
  };

  const editHistoryEntry = (entryIndex: number, newResult: boolean) => {
    if (!gameSession) return;
    
    const detailedHistory: QuestionHistoryEntry[] = [...gameSession.detailedHistory];
    const entry = detailedHistory[entryIndex];
    
    if (!entry) return;
    
    // Find the team that answered this question
    const teams: Team[] = [...gameSession.teams];
    const teamIndex = teams.findIndex(team => team.id === entry.teamId);
    
    if (teamIndex === -1) return;
    
    // Reverse the previous scoring
    if (entry.wasCorrect) {
      teams[teamIndex].score -= entry.points;
      teams[teamIndex].correctAnswers -= 1;
    }
    
    // Apply new scoring
    const points = difficultyConfig[entry.difficulty as Difficulty].points;
    if (newResult) {
      teams[teamIndex].score += points;
      teams[teamIndex].correctAnswers += 1;
      entry.points = points;
    } else {
      entry.points = 0;
    }
    
    entry.wasCorrect = newResult;
    
    updateGameMutation.mutate({
      teams: teams,
      detailedHistory: detailedHistory,
    });
    
    toast({
      title: "History Updated",
      description: `Question result changed to ${newResult ? "correct" : "incorrect"}`,
    });
  };

  const startEditingTeamName = (teamId: string, currentName: string) => {
    setEditingTeamId(teamId);
    setEditingTeamName(currentName);
  };

  const saveTeamName = () => {
    if (!gameSession || !editingTeamId || !editingTeamName.trim()) return;

    const updatedTeams = gameSession.teams.map(team =>
      team.id === editingTeamId ? { ...team, name: editingTeamName.trim() } : team
    );

    updateGameMutation.mutate({
      teams: updatedTeams,
    });

    setEditingTeamId(null);
    setEditingTeamName("");
  };

  const cancelEditingTeamName = () => {
    setEditingTeamId(null);
    setEditingTeamName("");
  };

  if (isLoading || !gameSession) {
    return <div className="text-center py-8">Loading game...</div>;
  }

  const teams: Team[] = gameSession.teams;
  const currentTeam = gameSession.currentTeamIndex !== null ? teams[gameSession.currentTeamIndex] : null;

  return (
    <div className="space-y-6">
      {/* Game Phase Banner - Always visible */}
      <div className="bg-gray-200 relative overflow-hidden mb-6 rounded-xl border-2 border-gray-300">
        <div className="px-6 py-8 relative z-10">
          <div className="text-center">
            {/* Floating Icons */}
            <div className="absolute top-2 left-4 opacity-30 animate-bounce">
              <Gamepad2 size={20} className="transform rotate-12 text-gray-500" />
            </div>
            <div className="absolute top-3 right-6 opacity-30 animate-bounce delay-300">
              <Users size={18} className="transform -rotate-12 text-gray-500" />
            </div>
            
            {/* Main Content */}
            <div className="relative">
              <h3 className="text-2xl md:text-3xl font-bold mb-2 text-gray-800">
                🎮 {gameSession?.teams[gameSession?.currentTeamIndex ?? 0]?.name || 'Team'}'s Turn
              </h3>
              <p className="text-lg text-gray-600 font-medium">
                {gamePhase === "difficulty-selection" 
                  ? `Choose your question difficulty • ${gameTypeConfig[selectedGameType]?.description || 'Test your knowledge'}` 
                  : `${gameSession?.teams[gameSession?.currentTeamIndex ?? 0]?.name || 'Team'} is answering the question.`
                }
              </p>
            </div>
          </div>
        </div>
        
        {/* Subtle background pattern */}
        <div className="absolute inset-0 opacity-5">
          <div className="absolute top-0 left-0 w-full h-full">
            <svg viewBox="0 0 100 100" className="w-full h-full">
              <defs>
                <pattern id="dots" patternUnits="userSpaceOnUse" width="10" height="10">
                  <circle cx="5" cy="5" r="1" fill="gray"/>
                </pattern>
              </defs>
              <rect width="100" height="100" fill="url(#dots)" />
            </svg>
          </div>
        </div>
      </div>



      {/* Game Type Selection Cards */}
      {gamePhase === "difficulty-selection" && (
        <div className="mb-6">
          <h4 className="text-lg font-semibold text-gray-800 mb-4 text-center">Choose game category</h4>
          <div className="overflow-x-auto pb-4">
            <div className="flex gap-4 px-2 py-2" style={{ minWidth: 'max-content' }}>
              {(Object.keys(gameTypeConfig) as GameType[]).map((gameType) => {
                const config = gameTypeConfig[gameType];
                const IconComponent = config.icon;
                const isSelected = selectedGameType === gameType;
                
                return (
                  <div
                    key={gameType}
                    onClick={() => setSelectedGameType(gameType)}
                    className={`relative flex-shrink-0 w-32 h-32 rounded-xl border-2 cursor-pointer transition-all duration-200 transform hover:scale-105 ${
                      isSelected 
                        ? `${config.bgColor} ${config.borderColor} ring-2 ring-gray-300 shadow-lg scale-105` 
                        : `bg-gray-50 border-gray-200 hover:bg-gray-100`
                    }`}
                  >
                    <div className="flex flex-col items-center justify-center h-full p-3 text-center">
                      <IconComponent 
                        size={32} 
                        className={`mb-2 ${isSelected ? config.iconColor : 'text-gray-400'}`} 
                      />
                      <div className={`text-sm font-semibold ${isSelected ? 'text-gray-800' : 'text-gray-600'}`}>
                        {config.label}
                      </div>
                    </div>
                    {isSelected && (
                      <div className="absolute top-1 right-1 w-5 h-5 bg-gray-600 rounded-full flex items-center justify-center">
                        <Check size={12} className="text-white" />
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      )}

      {/* Question Display */}
      {gamePhase === "difficulty-selection" && (
        <>
          <h4 className="text-xl font-bold text-gray-800 mb-4 text-center">Choose a question type</h4>
        </>
      )}
      
      {gamePhase === "difficulty-selection" && (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
          {(Object.keys(difficultyConfig) as Difficulty[]).map((difficulty) => {
            const config = difficultyConfig[difficulty];
            return (
              <Button
                key={difficulty}
                onClick={() => selectDifficulty(difficulty)}
                disabled={fetchQuestionMutation.isPending}
                className={`${config.bgColor} ${config.hoverColor} text-white py-8 px-8 text-xl font-semibold transition-all duration-200 transform hover:scale-105 border-4 border-white/20`}
              >
                <div className="text-center">
                  <div className="text-3xl font-bold">{difficulty.toUpperCase()}</div>
                  <div className="text-base opacity-90">{config.points} Point{config.points !== 1 ? 's' : ''}</div>
                </div>
              </Button>
            );
          })}
        </div>
      )}

      {gamePhase === "question-display" && currentQuestion && (
        <>
          {/* Question */}
          <div className="bg-gradient-to-r from-gray-50 to-gray-100 p-6 rounded-xl border-2 border-gray-200 mb-6">
            <div className="text-center">
              <div className="text-sm font-semibold text-gray-600 mb-2">
                {selectedDifficulty?.toUpperCase()}
              </div>
              <h4 className="text-2xl font-bold text-gray-800 mb-4">{currentQuestion.question}</h4>
              <div className="text-sm text-gray-600 mb-2">{currentQuestion.reference}</div>
              <div className="flex items-center justify-center gap-2">
                <div className="text-base text-gray-700 italic">Answer:</div>
                <div className={`text-base text-gray-700 italic transition-all duration-200 ${!answerVisible ? 'blur-sm select-none' : ''}`}>
                  {currentQuestion.answer}
                </div>
                <Button
                  onClick={() => setAnswerVisible(!answerVisible)}
                  size="sm"
                  className="bg-gray-200 hover:bg-gray-300 text-gray-700 p-1 ml-2"
                >
                  {answerVisible ? <EyeOff size={16} className="text-gray-700" /> : <Eye size={16} className="text-gray-700" />}
                </Button>
              </div>
            </div>
          </div>

          {/* Scoring buttons - Only visible when question is displayed */}
          {!questionAnswered && (
            <>
              <h4 className="text-lg font-semibold text-gray-800 mb-3 text-center">Choose the team's answer</h4>
              <div className="grid grid-cols-2 gap-6 mb-6">
                <Button
                  onClick={() => markCorrect(false)}
                  className="w-full bg-gradient-to-r from-gray-600 to-gray-700 text-white py-8 px-8 font-semibold hover:from-gray-700 hover:to-gray-800 transition-all duration-200 flex items-center justify-center border-4 border-white/20"
                  style={{ fontSize: '30px' }}
                >
                  Correct
                </Button>
                <Button
                  onClick={markIncorrect}
                  className="w-full bg-gradient-to-r from-gray-700 to-gray-800 text-white py-8 px-8 font-semibold hover:from-gray-800 hover:to-gray-900 transition-all duration-200 flex items-center justify-center border-4 border-white/20"
                  style={{ fontSize: '30px' }}
                >
                  Wrong
                </Button>
              </div>
            </>
          )}

          {/* Next Question Button - Only visible after question is answered */}
          {questionAnswered && (
            <div className="flex justify-center">
              <Button
                onClick={nextQuestion}
                className="bg-gradient-to-r from-gray-700 to-gray-900 text-white py-8 px-8 text-xl font-semibold hover:from-gray-800 hover:to-black transition-all duration-200 transform hover:scale-105 border-4 border-white/20"
                style={{ minWidth: '200px' }}
              >
                Next Question
              </Button>
            </div>
          )}
        </>
      )}





      {/* Game Status - Combined Scores and History */}
      <Card className="border-4 border-gray-200 shadow-xl">
        <CardContent className="p-6">
          {/* Tab Navigation */}
          <div className="border-b border-gray-200 mb-6">
            <nav className="flex space-x-8">
              <button
                onClick={() => setShowHistory(false)}
                className={`py-2 px-1 border-b-2 font-medium text-sm transition-all duration-200 flex items-center gap-2 ${
                  !showHistory
                    ? 'border-gray-600 text-gray-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                <Users size={16} />
                Teams & Scores
              </button>
              <button
                onClick={() => setShowHistory(true)}
                className={`py-2 px-1 border-b-2 font-medium text-sm transition-all duration-200 flex items-center gap-2 ${
                  showHistory
                    ? 'border-gray-600 text-gray-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                <History size={16} />
                History {gameSession.detailedHistory && gameSession.detailedHistory.length > 0 ? `(${gameSession.detailedHistory.length})` : ''}
              </button>
            </nav>
          </div>

          {/* Teams & Scores View */}
          {!showHistory && (
            <>
              <div className="space-y-2">
                {teams.filter((team, index) => {
                  // Always show all teams if there are only 2 teams
                  if (teams.length <= 2) return true;
                  if (teamsExpanded) return true;
                  // Only show current team when collapsed (simplified logic to prevent bounce)
                  return index === gameSession.currentTeamIndex;
                }).map((team, originalIndex) => {
                  const index = teams.findIndex(t => t.id === team.id);
                  const textClass = "text-gray-800";

                  const progressWidth = (team.score / (gameSession.targetScore || 10)) * 100;
                  
                  // Animation classes for correct/incorrect feedback
                  const animationClass = teamAnimations[team.id] === 'correct' 
                    ? 'animate-correct-glow text-green-700' 
                    : teamAnimations[team.id] === 'incorrect' 
                    ? 'animate-incorrect-shake text-red-700' 
                    : '';

                  // Transition classes for team switching - only when not expanding/collapsing
                  const isCurrentTeam = index === gameSession.currentTeamIndex;
                  const isPreviousTeam = teamTransitioning && prevTeamIndexRef.current !== null && index === prevTeamIndexRef.current;
                  
                  // Disable transition animations during expand/collapse to prevent bounce
                  const transitionClass = '';
                  
                  return (
                    <div key={team.id} className={`${transitionClass} py-1 ${index === gameSession.currentTeamIndex ? 'font-bold' : ''} transition-all duration-200 ease-in-out`}>
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-2 flex-1">
                          {editingTeamId === team.id ? (
                            <div className="flex items-center gap-2 flex-1">
                              <Input
                                value={editingTeamName}
                                onChange={(e) => setEditingTeamName(e.target.value)}
                                onKeyDown={(e) => {
                                  if (e.key === 'Enter') saveTeamName();
                                  if (e.key === 'Escape') cancelEditingTeamName();
                                }}
                                className="text-sm font-semibold border border-gray-400 focus:border-gray-600"
                                autoFocus
                              />
                              <Button
                                onClick={saveTeamName}
                                size="sm"
                                className="bg-gray-600 hover:bg-gray-700 text-white px-2 py-1"
                              >
                                <Check size={12} />
                              </Button>
                              <Button
                                onClick={cancelEditingTeamName}
                                size="sm"
                                className="bg-gray-200 hover:bg-gray-300 text-gray-700 px-2 py-1"
                              >
                                <X size={12} className="text-gray-700" />
                              </Button>
                            </div>
                          ) : (
                            <div className="flex items-center gap-2 flex-1">
                              <span className={`${animationClass || textClass} text-sm ${index === gameSession.currentTeamIndex ? 'font-bold' : 'font-medium'}`}>{team.name}</span>
                              <Progress value={progressWidth} className="h-2 bg-white [&>div]:bg-gray-600 flex-1 hidden" />
                              <Button
                                onClick={() => startEditingTeamName(team.id, team.name)}
                                size="sm"
                                className="bg-transparent hover:bg-gray-200 text-gray-500 hover:text-gray-700 p-1"
                              >
                                <Edit2 size={10} className="text-gray-500" />
                              </Button>
                            </div>
                          )}
                        </div>
                        <div className={`text-lg font-bold ${animationClass || textClass} ml-2`}>{team.score}</div>
                      </div>
                    </div>
                  );
                })}
              </div>
              
              {/* Expand/Collapse Teams Button - Only show if 3+ teams */}
              {teams.length >= 3 && (
                <div className="text-center mt-4">
                  <Button
                    onClick={() => setTeamsExpanded(!teamsExpanded)}
                    className="bg-gray-200 hover:bg-gray-300 text-gray-700 text-sm transition-all duration-200"
                  >
                    {teamsExpanded ? "Collapse Teams" : "Expand Teams"}
                  </Button>
                </div>
              )}
            </>
          )}

          {/* Question History View */}
          {showHistory && (
            <div className="space-y-4 max-h-96 overflow-y-auto">
              {gameSession.detailedHistory.map((entry: QuestionHistoryEntry, index: number) => (
                <div key={index} className={`p-4 rounded-xl border-2 ${entry.wasCorrect ? 'bg-gray-100 border-gray-300' : 'bg-gray-50 border-gray-200'}`}>
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-2">
                        <Badge className={`${entry.wasCorrect ? 'bg-gray-700' : 'bg-gray-600'} text-white`}>
                          {entry.teamName}
                        </Badge>
                        <Badge variant="outline">{entry.difficulty}</Badge>
                        <Badge variant="outline">{entry.points} pts</Badge>
                      </div>
                      <h4 className="font-semibold text-gray-800 mb-2">{entry.question}</h4>
                      <p className="text-gray-600 mb-1"><strong>Answer:</strong> {entry.answer}</p>
                      <p className="text-gray-500 text-sm">{entry.reference}</p>
                    </div>
                    <div className="flex gap-2 ml-4">
                      <Button
                        onClick={() => editHistoryEntry(index, true)}
                        disabled={entry.wasCorrect}
                        size="sm"
                        className="bg-gray-600 hover:bg-gray-700 text-white px-2 py-1"
                      >
                        <Check size={14} />
                      </Button>
                      <Button
                        onClick={() => editHistoryEntry(index, false)}
                        disabled={!entry.wasCorrect}
                        size="sm"
                        className="bg-gray-700 hover:bg-gray-800 text-white px-2 py-1"
                      >
                        <X size={14} />
                      </Button>
                    </div>
                  </div>
                </div>
              ))}
              {gameSession.detailedHistory.length === 0 && (
                <div className="text-center text-gray-500 py-8">
                  No questions answered yet
                </div>
              )}
            </div>
          )}

        </CardContent>
      </Card>

      {/* Game Code Display */}
      <div className="text-center mt-4 text-gray-600 hidden">
        <p className="text-sm">Game Code: <span className="font-mono font-semibold text-gray-800">{gameCode}</span></p>
      </div>
    </div>
  );
}
