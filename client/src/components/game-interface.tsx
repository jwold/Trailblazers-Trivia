import { useState, useEffect, useRef } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { Input } from "@/components/ui/input";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiRequest } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";
import { Users, Gamepad2, Check, X, SkipForward, Square, History, Edit2 } from "lucide-react";
import { type Team, type TriviaQuestion, type ClientGameSession, type QuestionHistoryEntry } from "@shared/schema";
import { createConfetti, createEncouragement } from "../lib/game-logic";

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
      }, 1000); // Total duration: 400ms fade-out + 600ms fade-in
    }
    
    prevTeamIndexRef.current = currentTeamIndex;
  }, [gameSession?.currentTeamIndex, teamsExpanded]);

  const fetchQuestionMutation = useMutation({
    mutationFn: async (difficulty: string) => {
      const response = await apiRequest("GET", `/api/games/${gameCode}/question/${difficulty}`);
      return response.json();
    },
    onSuccess: (question: TriviaQuestion) => {
      setCurrentQuestion(question);
      setGamePhase("question-display");
      setQuestionAnswered(false);
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
    
    createConfetti();
    
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
      {/* Score Display */}
      <Card className="border-4 border-gray-200 shadow-xl">
        <CardContent className="p-6">
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {teams.filter((team, index) => teamsExpanded || index === gameSession.currentTeamIndex).map((team, originalIndex) => {
              const index = teams.findIndex(t => t.id === team.id);
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

              const progressWidth = (team.score / (gameSession.targetScore || 10)) * 100;
              
              // Animation classes for correct/incorrect feedback
              const animationClass = teamAnimations[team.id] === 'correct' 
                ? 'animate-correct-glow bg-green-200 border-green-400 shadow-lg shadow-green-300/50' 
                : teamAnimations[team.id] === 'incorrect' 
                ? 'animate-incorrect-shake bg-red-200 border-red-400 shadow-lg shadow-red-300/50' 
                : '';

              // Transition classes for team switching
              const transitionClass = !teamsExpanded && teamTransitioning 
                ? 'animate-team-fade-out'
                : !teamsExpanded && !teamTransitioning
                ? 'animate-team-fade-in'
                : '';
              
              return (
                <div key={team.id} className={`${animationClass || colorClass} ${transitionClass} p-4 rounded-xl border-2 ${index === gameSession.currentTeamIndex ? 'ring-4 ring-gray-400' : ''} transition-all duration-300`}>
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
                            className="text-lg font-bold border-2 border-gray-400 focus:border-gray-600"
                            autoFocus
                          />
                          <Button
                            onClick={saveTeamName}
                            size="sm"
                            className="bg-gray-600 hover:bg-gray-700 text-white px-2 py-1"
                          >
                            <Check size={14} />
                          </Button>
                          <Button
                            onClick={cancelEditingTeamName}
                            size="sm"
                            className="bg-gray-200 hover:bg-gray-300 text-gray-700 px-2 py-1"
                          >
                            <X size={14} className="text-gray-700" />
                          </Button>
                        </div>
                      ) : (
                        <div className="flex items-center gap-2 flex-1">
                          <h4 className={`font-bold ${textClass} text-lg flex-1`}>{team.name}</h4>
                          <div className="w-16 mr-2">
                            <Progress value={progressWidth} className="h-2 bg-white [&>div]:bg-gray-600" />
                          </div>
                          <Button
                            onClick={() => startEditingTeamName(team.id, team.name)}
                            size="sm"
                            className="bg-gray-200 hover:bg-gray-300 text-gray-700 p-1"
                          >
                            <Edit2 size={14} className="text-gray-700" />
                          </Button>
                        </div>
                      )}
                    </div>
                    <div className={`text-3xl font-bold ${textClass} ml-2`}>{team.score}</div>
                  </div>

                </div>
              );
            })}
          </div>
          
          {/* Expand/Collapse Teams Button */}
          <div className="text-center mt-4">
            <Button
              onClick={() => setTeamsExpanded(!teamsExpanded)}
              className="bg-gray-200 hover:bg-gray-300 text-gray-700 text-sm"
            >
              {teamsExpanded ? "Collapse Teams" : "Expand Teams"}
            </Button>
          </div>
        </CardContent>
      </Card>

      

      {/* Question Display */}
      <Card className="border-4 border-gray-200 shadow-xl">
        <CardContent className="p-6">
          {gamePhase === "difficulty-selection" && (
            <>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
                {(Object.keys(difficultyConfig) as Difficulty[]).map((difficulty) => {
                  const config = difficultyConfig[difficulty];
                  return (
                    <Button
                      key={difficulty}
                      onClick={() => selectDifficulty(difficulty)}
                      disabled={fetchQuestionMutation.isPending}
                      className={`${config.bgColor} ${config.hoverColor} text-white py-6 px-6 text-lg font-semibold transition-all duration-200 transform hover:scale-105 border-4 border-white/20`}
                    >
                      <div className="text-center">
                        <div className="text-2xl font-bold">{difficulty.toUpperCase()}</div>
                        <div className="text-sm opacity-90">{config.points} Points</div>
                      </div>
                    </Button>
                  );
                })}
              </div>


            </>
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
                  <div className="text-base text-gray-700 italic">Answer: {currentQuestion.answer}</div>
                </div>
              </div>

              {/* Scoring buttons - Only visible when question is displayed */}
              {!questionAnswered && (
                <div className="grid grid-cols-2 gap-3 mb-6">
                  <Button
                    onClick={() => markCorrect(false)}
                    className="w-full bg-gradient-to-r from-gray-600 to-gray-700 text-white py-4 px-4 font-semibold hover:from-gray-700 hover:to-gray-800 transition-all duration-200"
                  >
                    <Check size={24} />
                  </Button>
                  <Button
                    onClick={markIncorrect}
                    className="w-full bg-gradient-to-r from-gray-700 to-gray-800 text-white py-4 px-4 font-semibold hover:from-gray-800 hover:to-gray-900 transition-all duration-200"
                  >
                    <X size={24} />
                  </Button>
                </div>
              )}

              {/* Next Question Button - Only visible after question is answered */}
              {questionAnswered && (
                <div className="text-center">
                  <Button
                    onClick={nextQuestion}
                    className="bg-gradient-to-r from-gray-700 to-gray-900 text-white py-6 px-12 text-xl font-bold hover:from-gray-800 hover:to-black transition-all duration-200 transform hover:scale-105 shadow-2xl border-4 border-gray-400 ring-4 ring-gray-300"
                  >
                    <SkipForward className="mr-3" size={24} />
                    Next Question
                  </Button>
                </div>
              )}

              
            </>
          )}


        </CardContent>
      </Card>

      {/* Question History */}
      {showHistory && (
        <Card className="border-4 border-gray-200 shadow-xl">
          <CardContent className="p-6">
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center">
                <div className="bg-gray-600 p-3 rounded-full mr-4">
                  <History className="text-white" size={20} />
                </div>
                <h3 className="text-xl font-bold text-gray-800">Question History</h3>
              </div>
              <Button
                onClick={() => setShowHistory(false)}
                size="sm"
                className="bg-gray-200 hover:bg-gray-300 text-gray-700"
              >
                ×
              </Button>
            </div>
            
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
          </CardContent>
        </Card>
      )}

      {/* History Button */}
      {gameSession.detailedHistory && gameSession.detailedHistory.length > 0 && (
        <div className="text-center mb-4">
          <Button
            onClick={() => setShowHistory(!showHistory)}
            className="bg-gray-200 hover:bg-gray-300 text-gray-700 py-3 px-6 font-semibold transition-all duration-200"
          >
            <History className="mr-2 text-gray-700" size={16} />
            {showHistory ? 'Hide History' : 'Show History'}
          </Button>
        </div>
      )}

      {/* End Game Button */}
      <div className="text-center">
        <Button
          onClick={endGame}
          className="bg-gray-200 hover:bg-gray-300 text-gray-700 py-4 px-6 font-semibold transition-all duration-200"
        >
          End Game
        </Button>
      </div>

      {/* Game Code Display */}
      <div className="text-center mt-4 text-gray-600 hidden">
        <p className="text-sm">Game Code: <span className="font-mono font-semibold text-gray-800">{gameCode}</span></p>
      </div>
    </div>
  );
}
