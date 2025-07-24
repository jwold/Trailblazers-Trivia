import { useState, useEffect, useRef } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiRequest } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";
import { Users, Gamepad2, Check, X, SkipForward, Eye, Square, History, Edit2 } from "lucide-react";
import { type Team, type TriviaQuestion, type GameSession, type QuestionHistoryEntry } from "@shared/schema";
import { createConfetti, createEncouragement } from "../lib/game-logic";

interface GameInterfaceProps {
  gameCode: string;
  onGameEnd: () => void;
}

type GamePhase = "difficulty-selection" | "question-display" | "answer-reveal";
type Difficulty = "Easy" | "Medium" | "Hard";

const difficultyConfig = {
  Easy: { points: 1, color: "green", bgColor: "bg-green-500", hoverColor: "hover:bg-green-600" },
  Medium: { points: 2, color: "yellow", bgColor: "bg-yellow-500", hoverColor: "hover:bg-yellow-600" },
  Hard: { points: 3, color: "red", bgColor: "bg-red-500", hoverColor: "hover:bg-red-600" },
};

export default function GameInterface({ gameCode, onGameEnd }: GameInterfaceProps) {
  const [gamePhase, setGamePhase] = useState<GamePhase>("difficulty-selection");
  const [currentQuestion, setCurrentQuestion] = useState<TriviaQuestion | null>(null);
  const [selectedDifficulty, setSelectedDifficulty] = useState<Difficulty | null>(null);
  const [showHistory, setShowHistory] = useState(false);
  const [questionNumber, setQuestionNumber] = useState(1);
  const { toast } = useToast();
  const queryClient = useQueryClient();

  const { data: gameSession, isLoading } = useQuery<GameSession>({
    queryKey: ["/api/games", gameCode],
    refetchInterval: 1000,
  });

  const fetchQuestionMutation = useMutation({
    mutationFn: async (difficulty: string) => {
      const response = await apiRequest("GET", `/api/games/${gameCode}/question/${difficulty}`);
      return response.json();
    },
    onSuccess: (question: TriviaQuestion) => {
      setCurrentQuestion(question);
      setGamePhase("question-display");
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
    mutationFn: async (updates: Partial<GameSession>) => {
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

  const markCorrect = () => {
    if (!gameSession || !selectedDifficulty || !currentQuestion) return;
    
    createConfetti();
    createEncouragement("Awesome! Great job!");
    
    const teams: Team[] = [...gameSession.teams];
    const currentTeamIndex = gameSession.currentTeamIndex;
    const points = difficultyConfig[selectedDifficulty].points;
    const currentTeam = teams[currentTeamIndex];
    
    // Update current team's score
    teams[currentTeamIndex].score += points;
    teams[currentTeamIndex].correctAnswers += 1;
    
    // Add question to history
    const questionHistory: number[] = [...gameSession.questionHistory, currentQuestion.id];
    
    // Add detailed history entry
    const detailedHistory: QuestionHistoryEntry[] = JSON.parse(gameSession.detailedHistory || "[]");
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
    const hasWinner = teams[currentTeamIndex].score >= gameSession.targetScore;
    
    updateGameMutation.mutate({
      teams: teams,
      questionHistory: questionHistory,
      detailedHistory: JSON.stringify(detailedHistory),
      gamePhase: hasWinner ? "victory" : "playing",
    });
    
    if (hasWinner) {
      setTimeout(() => onGameEnd(), 2000);
    } else {
      revealAnswer();
    }
  };

  const markIncorrect = () => {
    if (!gameSession || !selectedDifficulty || !currentQuestion) return;
    
    createEncouragement("Nice try! Keep going!");
    
    const currentTeam = gameSession.teams[gameSession.currentTeamIndex];
    
    // Add detailed history entry for incorrect answer
    const detailedHistory: QuestionHistoryEntry[] = JSON.parse(gameSession.detailedHistory || "[]");
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
    
    // Move to next team
    const nextTeamIndex = (gameSession.currentTeamIndex + 1) % gameSession.teams.length;
    
    updateGameMutation.mutate({
      currentTeamIndex: nextTeamIndex,
      detailedHistory: JSON.stringify(detailedHistory),
    });
    
    revealAnswer();
  };

  const revealAnswer = () => {
    setGamePhase("answer-reveal");
  };

  const nextQuestion = () => {
    if (!gameSession || !currentQuestion) return;
    
    // Move to next team if not already moved
    let nextTeamIndex = gameSession.currentTeamIndex;
    if (gamePhase !== "answer-reveal") {
      nextTeamIndex = (gameSession.currentTeamIndex + 1) % gameSession.teams.length;
    }
    
    // Add question to history
    const questionHistory: number[] = [...gameSession.questionHistory, currentQuestion.id];
    
    updateGameMutation.mutate({
      currentTeamIndex: nextTeamIndex,
      questionHistory: questionHistory,
    });
    
    setQuestionNumber(prev => prev + 1);
    setGamePhase("difficulty-selection");
    setCurrentQuestion(null);
    setSelectedDifficulty(null);
  };

  const skipQuestion = () => {
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
    
    const detailedHistory: QuestionHistoryEntry[] = JSON.parse(gameSession.detailedHistory || "[]");
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
      detailedHistory: JSON.stringify(detailedHistory),
    });
    
    toast({
      title: "History Updated",
      description: `Question result changed to ${newResult ? "correct" : "incorrect"}`,
    });
  };

  if (isLoading || !gameSession) {
    return <div className="text-center py-8">Loading game...</div>;
  }

  const teams: Team[] = gameSession.teams;
  const currentTeam = teams[gameSession.currentTeamIndex];

  return (
    <div className="space-y-6">
      {/* Score Display */}
      <Card className="border-4 border-brand-blue/20 shadow-xl">
        <CardContent className="p-6">
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {teams.map((team, index) => {
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

              const progressClass = team.color === "blue" ? "bg-blue-500" :
                                   team.color === "green" ? "bg-green-500" :
                                   team.color === "yellow" ? "bg-yellow-500" :
                                   team.color === "red" ? "bg-red-500" :
                                   team.color === "purple" ? "bg-purple-500" :
                                   "bg-orange-500";

              const progressWidth = (team.score / gameSession.targetScore) * 100;
              
              return (
                <div key={team.id} className={`${colorClass} p-4 rounded-xl border-2 ${index === gameSession.currentTeamIndex ? 'ring-4 ring-yellow-400' : ''}`}>
                  <div className="flex items-center justify-between">
                    <div>
                      <h4 className={`font-bold ${textClass} text-lg`}>{team.name}</h4>
                      <p className={textClass.replace('800', '600')}>Team Score</p>
                    </div>
                    <div className={`text-3xl font-bold ${textClass}`}>{team.score}</div>
                  </div>
                  <div className="mt-2">
                    <Progress value={progressWidth} className="h-3" />
                  </div>
                </div>
              );
            })}
          </div>
        </CardContent>
      </Card>

      

      {/* Question Display */}
      <Card className="border-4 border-brand-green/20 shadow-xl">
        <CardContent className="p-6">
          {gamePhase === "difficulty-selection" && (
            <>
              <h3 className="text-xl font-bold text-gray-800 mb-6 text-center">Choose Your Difficulty</h3>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
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
              <div className="bg-gradient-to-r from-blue-50 to-green-50 p-6 rounded-xl border-2 border-blue-200 mb-6">
                <div className="text-center">
                  <div className="text-sm font-semibold text-gray-600 mb-2">
                    {selectedDifficulty?.toUpperCase()} QUESTION
                  </div>
                  <h4 className="text-2xl font-bold text-gray-800 mb-4">{currentQuestion.question}</h4>
                  <div className="text-sm text-gray-600">{currentQuestion.reference}</div>
                </div>
              </div>

              {/* Next Question Button - Always Visible */}
              <div className="text-center">
                <Button
                  onClick={nextQuestion}
                  disabled={true}
                  className="bg-gradient-to-r from-gray-400 to-gray-500 text-white py-4 px-8 text-lg font-semibold transition-all duration-200 opacity-50 cursor-not-allowed"
                >
                  <SkipForward className="mr-2" size={20} />
                  Next Question
                </Button>
                <p className="text-sm text-gray-500 mt-2">Mark answer as correct/incorrect first</p>
              </div>

              
            </>
          )}

          {gamePhase === "answer-reveal" && currentQuestion && (
            <>
              <div className="text-center mb-6">
                <div className="inline-flex items-center bg-gradient-to-r from-green-500 to-green-600 text-white px-6 py-3 rounded-full text-lg font-semibold">
                  <Check className="mr-2" size={20} />
                  Correct Answer
                </div>
              </div>

              <div className="bg-green-50 p-6 rounded-xl border-2 border-green-200 mb-6">
                <h4 className="text-2xl font-bold text-green-800 mb-4 text-center">{currentQuestion.answer}</h4>
                <div className="text-center">
                  <p className="text-green-700 mb-4">{currentQuestion.reference}</p>
                </div>
              </div>

              <div className="text-center">
                <Button
                  onClick={nextQuestion}
                  className="bg-gradient-to-r from-brand-blue to-blue-600 text-white py-6 px-12 text-xl font-bold hover:from-blue-600 hover:to-blue-700 transition-all duration-200 transform hover:scale-105 shadow-2xl border-4 border-white"
                >
                  <SkipForward className="mr-3" size={24} />
                  Next Question
                </Button>
                <div className="mt-3 text-sm text-blue-600 font-semibold">
                  Click to continue the game!
                </div>
              </div>
            </>
          )}
        </CardContent>
      </Card>

      {/* Question History */}
      {showHistory && (
        <Card className="border-4 border-purple-200 shadow-xl">
          <CardContent className="p-6">
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center">
                <div className="bg-purple-500 p-3 rounded-full mr-4">
                  <History className="text-white" size={20} />
                </div>
                <h3 className="text-xl font-bold text-gray-800">Question History</h3>
              </div>
              <Button
                onClick={() => setShowHistory(false)}
                variant="ghost"
                size="sm"
                className="text-gray-600 hover:text-gray-800"
              >
                ×
              </Button>
            </div>
            
            <div className="space-y-4 max-h-96 overflow-y-auto">
              {JSON.parse(gameSession.detailedHistory || "[]").map((entry: QuestionHistoryEntry, index: number) => (
                <div key={index} className={`p-4 rounded-xl border-2 ${entry.wasCorrect ? 'bg-green-50 border-green-200' : 'bg-red-50 border-red-200'}`}>
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-2">
                        <Badge className={`${entry.wasCorrect ? 'bg-green-500' : 'bg-red-500'} text-white`}>
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
                        className="bg-green-500 hover:bg-green-600 text-white px-2 py-1"
                      >
                        <Check size={14} />
                      </Button>
                      <Button
                        onClick={() => editHistoryEntry(index, false)}
                        disabled={!entry.wasCorrect}
                        size="sm"
                        className="bg-red-500 hover:bg-red-600 text-white px-2 py-1"
                      >
                        <X size={14} />
                      </Button>
                    </div>
                  </div>
                </div>
              ))}
              {JSON.parse(gameSession.detailedHistory || "[]").length === 0 && (
                <div className="text-center text-gray-500 py-8">
                  No questions answered yet
                </div>
              )}
            </div>
          </CardContent>
        </Card>
      )}

      {/* Leader Controls */}
      <Card className="border-4 border-brand-orange/20 shadow-xl">
        <CardContent className="p-6">
          

          <div className="grid grid-cols-2 md:grid-cols-5 gap-4 mb-6">
            <Button
              onClick={markCorrect}
              disabled={gamePhase !== "question-display"}
              className="bg-gradient-to-r from-green-500 to-green-600 text-white py-4 px-4 font-semibold hover:from-green-600 hover:to-green-700 transition-all duration-200"
            >
              <Check className="mb-2" size={20} />
              <div className="text-sm">Mark Correct</div>
            </Button>
            <Button
              onClick={markIncorrect}
              disabled={gamePhase !== "question-display"}
              className="bg-gradient-to-r from-red-500 to-red-600 text-white py-4 px-4 font-semibold hover:from-red-600 hover:to-red-700 transition-all duration-200"
            >
              <X className="mb-2" size={20} />
              <div className="text-sm">Mark Wrong</div>
            </Button>
            <Button
              onClick={skipQuestion}
              className="bg-gradient-to-r from-gray-500 to-gray-600 text-white py-4 px-4 font-semibold hover:from-gray-600 hover:to-gray-700 transition-all duration-200"
            >
              <SkipForward className="mb-2" size={20} />
              <div className="text-sm">Skip</div>
            </Button>
            <Button
              onClick={revealAnswer}
              disabled={gamePhase !== "question-display"}
              className="bg-gradient-to-r from-blue-500 to-blue-600 text-white py-4 px-4 font-semibold hover:from-blue-600 hover:to-blue-700 transition-all duration-200"
            >
              <Eye className="mb-2" size={20} />
              <div className="text-sm">Reveal</div>
            </Button>
            <Button
              onClick={() => setShowHistory(!showHistory)}
              className="bg-gradient-to-r from-purple-500 to-purple-600 text-white py-4 px-4 font-semibold hover:from-purple-600 hover:to-purple-700 transition-all duration-200"
            >
              <History className="mb-2" size={20} />
              <div className="text-sm">History</div>
            </Button>
          </div>

          <div className="text-center">
            <Button
              onClick={endGame}
              className="bg-gradient-to-r from-purple-500 to-purple-600 text-white py-3 px-6 font-semibold hover:from-purple-600 hover:to-purple-700 transition-all duration-200"
            >
              <Square className="mr-2" size={16} />
              End Game
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
