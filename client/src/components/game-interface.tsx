import { useState, useEffect, useRef } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { Input } from "@/components/ui/input";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiRequest } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";
import { Users, Gamepad2, Check, X, SkipForward, Square, History, Edit2, Eye, EyeOff } from "lucide-react";
import { type Team, type TriviaQuestion, type ClientGameSession, type QuestionHistoryEntry } from "@shared/schema";
// import { createConfetti, createEncouragement } from "../lib/game-logic";

interface GameInterfaceProps {
  gameCode: string;
  onGameEnd: () => void;
}

type GamePhase = "difficulty-selection" | "question-display";
type Difficulty = "Easy" | "Hard";


const difficultyConfig = {
  Easy: { points: 1, bibleAssistPoints: 0.5, color: "gray", bgColor: "bg-gray-600", hoverColor: "hover:bg-gray-700" },
  Hard: { points: 3, bibleAssistPoints: 1, color: "gray", bgColor: "bg-gray-800", hoverColor: "hover:bg-gray-900" },
};



export default function GameInterface({ gameCode, onGameEnd }: GameInterfaceProps) {
  const [gamePhase, setGamePhase] = useState<GamePhase>("question-display");
  const [currentQuestion, setCurrentQuestion] = useState<TriviaQuestion | null>(null);
  const [selectedDifficulty, setSelectedDifficulty] = useState<Difficulty>("Easy");
  const [lastSelectedDifficulty, setLastSelectedDifficulty] = useState<Difficulty>("Easy");
  const [easyQuestion, setEasyQuestion] = useState<TriviaQuestion | null>(null);
  const [hardQuestion, setHardQuestion] = useState<TriviaQuestion | null>(null);
  const [showHistory, setShowHistory] = useState(false);
  const [questionNumber, setQuestionNumber] = useState(1);
  const [questionAnswered, setQuestionAnswered] = useState(false);
  const [editingTeamId, setEditingTeamId] = useState<string | null>(null);
  const [editingTeamName, setEditingTeamName] = useState<string>("");
  const [teamAnimations, setTeamAnimations] = useState<Record<string, 'correct' | 'incorrect' | null>>({});
  const [teamsExpanded, setTeamsExpanded] = useState(false);
  const [teamTransitioning, setTeamTransitioning] = useState(false);
  const [answerVisible, setAnswerVisible] = useState(false);
  const [questionBlurred, setQuestionBlurred] = useState(true);

  const { toast } = useToast();
  const queryClient = useQueryClient();
  const prevTeamIndexRef = useRef<number | null>(null);

  const { data: gameSession, isLoading } = useQuery<ClientGameSession>({
    queryKey: ["/api/games", gameCode],
    refetchInterval: 1000,
  });

  // Auto-load questions when game session is first loaded
  useEffect(() => {
    if (gameSession && !easyQuestion && !hardQuestion && !fetchQuestionMutation.isPending) {
      fetchQuestionMutation.mutate("Easy");
      fetchQuestionMutation.mutate("Hard");
    }
  }, [gameSession, easyQuestion, hardQuestion]);

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
    mutationFn: async (difficulty: Difficulty) => {
      const response = await apiRequest("GET", `/api/games/${gameCode}/question/${difficulty}`);
      return response.json();
    },
    onSuccess: (question: TriviaQuestion, variables: Difficulty) => {
      if (variables === "Easy") {
        setEasyQuestion(question);
        // If this is the first question loaded, set it as current and select Easy
        if (gamePhase === "difficulty-selection") {
          setCurrentQuestion(question);
          setSelectedDifficulty("Easy");
          setGamePhase("question-display");
        } else if (selectedDifficulty === "Easy") {
          setCurrentQuestion(question);
        }
      } else {
        setHardQuestion(question);
        // If Hard is currently selected and this Hard question just loaded, show it
        if (selectedDifficulty === "Hard" && gamePhase === "question-display") {
          setCurrentQuestion(question);
        }
      }
      setQuestionAnswered(false);
      setAnswerVisible(false);
      setQuestionBlurred(true); // Reset blur for new questions
      setLastSelectedDifficulty(variables);
      // Clear any lingering animations when a new question loads
      setTeamAnimations({});
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
    setLastSelectedDifficulty(difficulty);
    
    // Auto-fetch both questions and start with Easy when first entering question mode
    if (gamePhase === "difficulty-selection") {
      // Fetch both Easy and Hard questions
      fetchQuestionMutation.mutate("Easy");
      fetchQuestionMutation.mutate("Hard");
      setGamePhase("question-display");
    }
  };

  const switchDifficulty = (difficulty: Difficulty) => {
    setSelectedDifficulty(difficulty);
    setLastSelectedDifficulty(difficulty);
    const targetQuestion = difficulty === "Easy" ? easyQuestion : hardQuestion;
    if (targetQuestion) {
      setCurrentQuestion(targetQuestion);
      setAnswerVisible(false); // Reset answer visibility when switching
      setQuestionBlurred(true); // Reset blur when switching questions
    } else {
      fetchQuestionMutation.mutate(difficulty);
    }
  };

  const markCorrect = (usedBibleAssist = false) => {
    if (!gameSession || !selectedDifficulty || !currentQuestion || gameSession.currentTeamIndex === null) return;
    
    const teams: Team[] = [...gameSession.teams];
    const currentTeamIndex = gameSession.currentTeamIndex;
    const currentTeam = teams[currentTeamIndex];
    
    // Animation disabled
    
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
    
    // Animation disabled
    
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
    setGamePhase("question-display");
    setCurrentQuestion(null);
    setEasyQuestion(null);
    setHardQuestion(null);
    setSelectedDifficulty(lastSelectedDifficulty);
    setQuestionAnswered(false);
    setAnswerVisible(false);
    setQuestionBlurred(true);
    // Clear any remaining team animations
    setTeamAnimations({});
    
    // Auto-load new questions
    setTimeout(() => {
      fetchQuestionMutation.mutate("Easy");
      fetchQuestionMutation.mutate("Hard");
    }, 100);
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





      {/* Loading state */}
      {(!easyQuestion && !hardQuestion && fetchQuestionMutation.isPending) && (
        <div className="text-center py-8">
          <div className="text-xl font-semibold text-gray-600">Loading questions...</div>
        </div>
      )}

      {gamePhase === "question-display" && (easyQuestion || hardQuestion) && (
        <>
          {/* Difficulty Tabs */}
          <Card className="border-4 border-gray-200 shadow-xl mb-6">
            <CardContent className="p-6">
              {/* Tab Navigation */}
              <div className="border-b border-gray-200 mb-6">
                <nav className="flex space-x-8">
                  <button
                    onClick={() => switchDifficulty("Easy")}
                    disabled={!easyQuestion}
                    className={`py-2 px-1 border-b-2 font-medium text-sm transition-all duration-200 flex items-center gap-2 ${
                      selectedDifficulty === "Easy"
                        ? 'border-gray-600 text-gray-600'
                        : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                    } ${!easyQuestion ? 'opacity-50 cursor-not-allowed' : ''}`}
                  >
                    Easy (1 Point)
                  </button>
                  <button
                    onClick={() => switchDifficulty("Hard")}
                    disabled={!hardQuestion}
                    className={`py-2 px-1 border-b-2 font-medium text-sm transition-all duration-200 flex items-center gap-2 ${
                      selectedDifficulty === "Hard"
                        ? 'border-gray-600 text-gray-600'
                        : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                    } ${!hardQuestion ? 'opacity-50 cursor-not-allowed' : ''}`}
                  >
                    Hard (3 Points)
                  </button>
                </nav>
              </div>

              {/* Question Content */}
              {currentQuestion && (
                <div className="text-center">
                  <div className="text-sm font-semibold text-gray-600 mb-2">
                    {gameSession?.category ? gameSession.category.charAt(0).toUpperCase() + gameSession.category.slice(1).replace('_', ' ') : ''} Trivia
                  </div>
                  <h4 
                    className={`text-2xl font-bold text-gray-800 mb-4 transition-all duration-300 cursor-pointer select-none ${
                      questionBlurred ? 'blur-md' : ''
                    }`}
                    onClick={() => setQuestionBlurred(false)}
                  >
                    {currentQuestion.question}
                  </h4>
                  {gameSession?.category === 'bible' && currentQuestion.reference && (
                    <div className="text-sm text-gray-600 mb-2">{currentQuestion.reference}</div>
                  )}
                  {!answerVisible ? (
                    <div className="text-center mt-4">
                      <Button
                        onClick={() => setAnswerVisible(true)}
                        className="bg-gray-600 hover:bg-gray-700 text-white px-6 py-2 text-sm font-medium"
                      >
                        Show Answer
                      </Button>
                    </div>
                  ) : (
                    <div 
                      onClick={() => setAnswerVisible(false)}
                      className="mt-4 p-4 bg-gray-50 rounded-lg border-2 border-gray-200 cursor-pointer hover:bg-gray-100 transition-colors duration-200"
                    >
                      <div className="flex items-center justify-center gap-2">
                        <div className="text-base text-gray-700 font-semibold">Answer:</div>
                        <div className="text-base text-gray-700 italic">
                          {currentQuestion.answer}
                        </div>
                      </div>
                    </div>
                  )}
                </div>
              )}
            </CardContent>
          </Card>

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
                  
                  // Animation classes for correct/incorrect feedback - disabled
                  const animationClass = '';

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
                      {gameSession?.category === 'bible' && entry.reference && (
                        <p className="text-gray-500 text-sm">{entry.reference}</p>
                      )}
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
