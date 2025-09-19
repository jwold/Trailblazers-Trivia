import { useState, useEffect, useRef } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { Input } from "@/components/ui/input";
import { useToast } from "@/hooks/use-toast";
import { Users, Gamepad2, Check, X, Square, Undo2, Edit2, Eye, EyeOff, Edit } from "lucide-react";
import { type Team, type TriviaQuestion, type ClientGameSession, staticGameService } from "@/services/static-game-service";

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
  const [gameSession, setGameSession] = useState<ClientGameSession | null>(null);
  const [gamePhase, setGamePhase] = useState<GamePhase>("difficulty-selection");
  const [currentQuestion, setCurrentQuestion] = useState<TriviaQuestion | null>(null);
  const [selectedDifficulty, setSelectedDifficulty] = useState<Difficulty>("Easy");
  const [easyQuestion, setEasyQuestion] = useState<TriviaQuestion | null>(null);
  const [hardQuestion, setHardQuestion] = useState<TriviaQuestion | null>(null);
  const [canUndo, setCanUndo] = useState(false);
  const [lastAction, setLastAction] = useState<{
    teamId: string;
    points: number;
    correct: boolean;
    questionId: number;
  } | null>(null);
  const [questionNumber, setQuestionNumber] = useState(1);
  const [questionAnswered, setQuestionAnswered] = useState(false);
  const [editingTeamId, setEditingTeamId] = useState<string | null>(null);
  const [editingTeamName, setEditingTeamName] = useState<string>("");
  const [teamAnimations, setTeamAnimations] = useState<Record<string, 'correct' | 'incorrect' | null>>({});
  const [teamsExpanded, setTeamsExpanded] = useState(false);
  const [answerVisible, setAnswerVisible] = useState(false);
  const [questionVisible, setQuestionVisible] = useState(true);
  const [isLoading, setIsLoading] = useState(true);
  const [loadingQuestions, setLoadingQuestions] = useState(false);

  const { toast } = useToast();

  // Load game session on mount
  useEffect(() => {
    const loadGame = async () => {
      try {
        const session = await staticGameService.getGame(gameCode);
        if (session) {
          setGameSession(session);
          // Load initial questions
          await loadQuestions();
        }
      } catch (error) {
        console.error('Failed to load game:', error);
        toast({
          title: "Error",
          description: "Failed to load game. Please try again.",
          variant: "destructive",
        });
      } finally {
        setIsLoading(false);
      }
    };
    loadGame();
  }, [gameCode]);

  const loadQuestions = async () => {
    setLoadingQuestions(true);
    try {
      // Load both easy and hard questions
      const [easy, hard] = await Promise.all([
        staticGameService.getRandomQuestion(gameCode, 'Easy'),
        staticGameService.getRandomQuestion(gameCode, 'Hard')
      ]);
      
      setEasyQuestion(easy);
      setHardQuestion(hard);
      
      // Set initial question to easy
      setCurrentQuestion(easy);
      setSelectedDifficulty('Easy');
      setGamePhase('question-display');
    } catch (error) {
      console.error('Failed to load questions:', error);
      toast({
        title: "Error",
        description: "Failed to load questions. Please try again.",
        variant: "destructive",
      });
    } finally {
      setLoadingQuestions(false);
    }
  };

  const handleAnswer = async (correct: boolean) => {
    if (!gameSession || !currentQuestion || questionAnswered) return;

    const currentTeam = gameSession.teams[gameSession.currentTeamIndex];
    const points = correct ? difficultyConfig[selectedDifficulty].points : 0;

    // Save undo information
    setLastAction({
      teamId: currentTeam.id,
      points,
      correct,
      questionId: currentQuestion.id
    });
    setCanUndo(true);

    // Update team score
    const updatedTeam = {
      ...currentTeam,
      score: currentTeam.score + points,
      correctAnswers: currentTeam.correctAnswers + (correct ? 1 : 0)
    };

    // Update game session
    const updatedTeams = [...gameSession.teams];
    updatedTeams[gameSession.currentTeamIndex] = updatedTeam;

    const nextTeamIndex = (gameSession.currentTeamIndex + 1) % gameSession.teams.length;
    
    const updatedSession = await staticGameService.updateGame(gameCode, {
      teams: updatedTeams,
      currentTeamIndex: nextTeamIndex,
      questionHistory: [...gameSession.questionHistory, currentQuestion.id],
      detailedHistory: [...gameSession.detailedHistory, {
        questionId: currentQuestion.id,
        teamId: currentTeam.id,
        correct,
        points,
        timestamp: new Date().toISOString()
      }]
    });

    setGameSession(updatedSession);
    setQuestionAnswered(true);

    // Show animation
    setTeamAnimations({ [currentTeam.id]: correct ? 'correct' : 'incorrect' });
    setTimeout(() => setTeamAnimations({}), 1500);

    // Check for game end
    if (updatedTeam.score >= gameSession.targetScore) {
      const finalSession = await staticGameService.updateGame(gameCode, {
        gamePhase: 'ended'
      });
      setGameSession(finalSession);
      setTimeout(onGameEnd, 1500);
      return;
    }
  };

  const handleNextQuestion = async () => {
    setQuestionAnswered(false);
    setAnswerVisible(false);
    setQuestionNumber(questionNumber + 1);
    setGamePhase('difficulty-selection');
    setCanUndo(false); // Can't undo after moving to next question
    setLastAction(null);
    await loadQuestions();
  };

  const handleUndo = async () => {
    if (!gameSession || !lastAction || !canUndo) return;

    // Find the team that answered
    const teamIndex = gameSession.teams.findIndex(t => t.id === lastAction.teamId);
    if (teamIndex === -1) return;

    // Revert the team's score
    const team = gameSession.teams[teamIndex];
    const revertedTeam = {
      ...team,
      score: team.score - lastAction.points,
      correctAnswers: team.correctAnswers - (lastAction.correct ? 1 : 0)
    };

    // Update teams array
    const updatedTeams = [...gameSession.teams];
    updatedTeams[teamIndex] = revertedTeam;

    // Go back to previous team
    const previousTeamIndex = teamIndex;

    // Remove last question from history
    const updatedQuestionHistory = gameSession.questionHistory.slice(0, -1);
    const updatedDetailedHistory = gameSession.detailedHistory.slice(0, -1);

    // Update game session
    const updatedSession = await staticGameService.updateGame(gameCode, {
      teams: updatedTeams,
      currentTeamIndex: previousTeamIndex,
      questionHistory: updatedQuestionHistory,
      detailedHistory: updatedDetailedHistory
    });

    setGameSession(updatedSession);
    setQuestionAnswered(false);
    setCanUndo(false);
    setLastAction(null);
    setTeamAnimations({});
  };


  const selectDifficulty = (difficulty: Difficulty) => {
    setSelectedDifficulty(difficulty);
    setCurrentQuestion(difficulty === 'Easy' ? easyQuestion : hardQuestion);
    setGamePhase('question-display');
  };

  const toggleAnswer = () => {
    setAnswerVisible(!answerVisible);
  };

  const handleUpdateTeamName = async (teamId: string, newName: string) => {
    if (!gameSession) return;

    const updatedTeams = gameSession.teams.map(team =>
      team.id === teamId ? { ...team, name: newName } : team
    );

    const updatedSession = await staticGameService.updateGame(gameCode, {
      teams: updatedTeams
    });

    setGameSession(updatedSession);
    setEditingTeamId(null);
    setEditingTeamName('');
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <div className="text-2xl font-bold mb-2">Loading Game...</div>
          <div className="text-gray-600 dark:text-gray-400">Game Code: {gameCode}</div>
        </div>
      </div>
    );
  }

  if (!gameSession) {
    return (
      <div className="text-center py-8">
        <div className="text-2xl font-bold text-red-600">Game not found</div>
        <Button onClick={onGameEnd} className="mt-4">
          Back to Home
        </Button>
      </div>
    );
  }

  const currentTeam = gameSession.teams[gameSession.currentTeamIndex];
  const currentBgColor = teamsExpanded ? "" : "dark:bg-gray-800";

  return (
    <div className="space-y-6">
      {/* Game Header */}
      <Card className={`border-4 border-gray-300 dark:border-gray-700 ${currentBgColor} transition-colors duration-500`}>
        <CardContent className="p-4">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-4">
              <Gamepad2 className="text-gray-700 dark:text-gray-300" size={24} />
              <span className="text-lg font-semibold text-gray-700 dark:text-gray-300">
                Question {questionNumber}
              </span>
            </div>
            <div className="flex items-center gap-2">
              <Badge variant="outline" className="text-gray-700 dark:text-gray-300 border-gray-400">
                {gameCode}
              </Badge>
              {canUndo && (
                <Button
                  onClick={handleUndo}
                  size="sm"
                  variant="ghost"
                  className="text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700"
                  title="Undo last answer"
                >
                  <Undo2 size={16} />
                </Button>
              )}
            </div>
          </div>

          {/* Score Progress */}
          <div className="space-y-3">
            <div className="flex items-center justify-between text-sm text-gray-600 dark:text-gray-400">
              <span>Target Score: {gameSession.targetScore}</span>
              <span>
                Leading: {[...gameSession.teams].sort((a, b) => b.score - a.score)[0].name}
              </span>
            </div>
            <Progress 
              value={(Math.max(...gameSession.teams.map(t => t.score)) / gameSession.targetScore) * 100} 
              className="h-2 bg-gray-200 dark:bg-gray-700"
            />
          </div>
        </CardContent>
      </Card>

      {/* Teams Display */}
      <div className="relative">
        <Button
          onClick={() => setTeamsExpanded(!teamsExpanded)}
          variant="ghost"
          className="absolute -top-2 right-0 z-10 text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700"
          size="sm"
        >
          <Users size={16} className="mr-1" />
          {teamsExpanded ? 'Collapse' : 'Expand'}
        </Button>

        <div className={`grid ${teamsExpanded ? 'grid-cols-2 md:grid-cols-3 gap-3' : 'grid-cols-1 gap-0'} transition-all duration-500`}>
          {gameSession.teams.map((team, index) => {
            const isCurrentTeam = index === gameSession.currentTeamIndex;
            const animationClass = teamAnimations[team.id];
            
            return (
              <Card 
                key={team.id} 
                className={`
                  transition-all duration-500 border-2
                  ${!teamsExpanded && !isCurrentTeam ? 'hidden' : ''}
                  ${isCurrentTeam && !teamsExpanded ? 'border-4 border-blue-500 dark:border-blue-400 shadow-lg scale-105' : 'border-gray-300 dark:border-gray-700'}
                  ${animationClass === 'correct' ? 'bg-green-100 dark:bg-green-900 border-green-500' : ''}
                  ${animationClass === 'incorrect' ? 'bg-red-100 dark:bg-red-900 border-red-500' : ''}
                `}
              >
                <CardContent className="p-4">
                  <div className="flex items-center justify-between mb-2">
                    {editingTeamId === team.id ? (
                      <div className="flex items-center gap-2 flex-1">
                        <Input
                          value={editingTeamName}
                          onChange={(e) => setEditingTeamName(e.target.value)}
                          onKeyPress={(e) => {
                            if (e.key === 'Enter') {
                              handleUpdateTeamName(team.id, editingTeamName);
                            }
                          }}
                          className="h-8"
                          autoFocus
                        />
                        <Button
                          size="sm"
                          onClick={() => handleUpdateTeamName(team.id, editingTeamName)}
                        >
                          <Check size={16} />
                        </Button>
                        <Button
                          size="sm"
                          variant="ghost"
                          onClick={() => {
                            setEditingTeamId(null);
                            setEditingTeamName('');
                          }}
                        >
                          <X size={16} />
                        </Button>
                      </div>
                    ) : (
                      <>
                        <h3 className="font-bold text-lg">{team.name}</h3>
                        <Button
                          size="sm"
                          variant="ghost"
                          onClick={() => {
                            setEditingTeamId(team.id);
                            setEditingTeamName(team.name);
                          }}
                          className="h-6 w-6 p-0"
                        >
                          <Edit2 size={14} />
                        </Button>
                      </>
                    )}
                  </div>
                  <div className="flex items-end justify-between">
                    <div>
                      <div className="text-3xl font-bold">{team.score}</div>
                      <div className="text-sm text-gray-600 dark:text-gray-400">
                        {team.correctAnswers} correct
                      </div>
                    </div>
                    {isCurrentTeam && !teamsExpanded && (
                      <Badge className="bg-blue-500 text-white">Current</Badge>
                    )}
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>
      </div>

      {/* Question Display */}
      {gamePhase === "difficulty-selection" && !loadingQuestions && (
        <Card className="border-4 border-gray-300 dark:border-gray-700">
          <CardContent className="p-8 text-center">
            <h2 className="text-2xl font-bold mb-6">Choose Difficulty</h2>
            <div className="grid grid-cols-2 gap-4 max-w-md mx-auto">
              <Button
                onClick={() => selectDifficulty('Easy')}
                className="h-24 text-lg font-bold bg-gray-600 hover:bg-gray-700"
              >
                <div>
                  <div>Easy</div>
                  <div className="text-sm font-normal">1 point</div>
                </div>
              </Button>
              <Button
                onClick={() => selectDifficulty('Hard')}
                className="h-24 text-lg font-bold bg-gray-800 hover:bg-gray-900"
              >
                <div>
                  <div>Hard</div>
                  <div className="text-sm font-normal">3 points</div>
                </div>
              </Button>
            </div>
          </CardContent>
        </Card>
      )}

      {gamePhase === "question-display" && currentQuestion && (
        <Card className="border-4 border-gray-300 dark:border-gray-700">
          <CardContent className="p-8">
            <div className="mb-6 flex items-center justify-between">
              <Badge className={`${difficultyConfig[selectedDifficulty].bgColor} text-white`}>
                {selectedDifficulty} - {difficultyConfig[selectedDifficulty].points} {difficultyConfig[selectedDifficulty].points === 1 ? 'point' : 'points'}
              </Badge>
              <Badge variant="outline">{currentQuestion.category}</Badge>
            </div>

            <div className="flex items-start gap-3 mb-8">
              <div className="text-2xl font-semibold leading-relaxed flex-1">
                {currentQuestion.question}
              </div>
              <Button
                onClick={toggleAnswer}
                variant="ghost"
                size="sm"
                className="p-2 hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
                title={answerVisible ? "Hide answer" : "Show answer"}
              >
                {answerVisible ? (
                  <EyeOff className="w-6 h-6 text-gray-600 dark:text-gray-400" />
                ) : (
                  <Eye className="w-6 h-6 text-gray-600 dark:text-gray-400" />
                )}
              </Button>
            </div>

            {answerVisible && (
              <div className="mb-6 p-4 bg-blue-50 dark:bg-blue-900 rounded-lg border-2 border-blue-200 dark:border-blue-700">
                <div className="font-semibold text-lg mb-2">Answer:</div>
                <div className="text-xl">{currentQuestion.answer}</div>
                {currentQuestion.reference && (
                  <div className="text-sm text-gray-600 dark:text-gray-400 mt-2">
                    Reference: {currentQuestion.reference}
                  </div>
                )}
              </div>
            )}

            <div className="flex gap-3 justify-center">
              {!questionAnswered ? (
                <>
                  <Button
                    onClick={() => handleAnswer(true)}
                    size="lg"
                    className="min-w-[120px] bg-green-600 hover:bg-green-700"
                  >
                    <Check className="mr-2" size={20} />
                    Correct
                  </Button>
                  <Button
                    onClick={() => handleAnswer(false)}
                    size="lg"
                    className="min-w-[120px] bg-red-600 hover:bg-red-700"
                  >
                    <X className="mr-2" size={20} />
                    Wrong
                  </Button>
                </>
              ) : (
                <Button
                  onClick={handleNextQuestion}
                  size="lg"
                  className="min-w-[200px]"
                >
                  Next Question
                </Button>
              )}
            </div>
          </CardContent>
        </Card>
      )}

      {/* Loading state for questions */}
      {loadingQuestions && (
        <Card className="border-4 border-gray-300 dark:border-gray-700">
          <CardContent className="p-8 text-center">
            <div className="text-xl">Loading questions...</div>
          </CardContent>
        </Card>
      )}

    </div>
  );
}