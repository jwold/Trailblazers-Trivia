import { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useToast } from "@/hooks/use-toast";
import { type TriviaQuestion, type ClientGameSession, staticGameService } from "@/services/static-game-service";

interface GameInterfaceProps {
  gameCode: string;
  onGameEnd: () => void;
  onTeamUpdate?: (teamName: string, score: number) => void;
}

type Difficulty = "easy" | "hard";

export default function GameInterface({ gameCode, onGameEnd, onTeamUpdate }: GameInterfaceProps) {
  const [gameSession, setGameSession] = useState<ClientGameSession | null>(null);
  const [easyQuestion, setEasyQuestion] = useState<TriviaQuestion | null>(null);
  const [hardQuestion, setHardQuestion] = useState<TriviaQuestion | null>(null);
  const [selectedTab, setSelectedTab] = useState<Difficulty>(() => {
    const saved = localStorage.getItem('preferredDifficulty');
    return (saved === 'easy' || saved === 'hard') ? saved : 'easy';
  });
  const [answerVisible, setAnswerVisible] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [loadingQuestions, setLoadingQuestions] = useState(false);
  const [teamsExpanded, setTeamsExpanded] = useState(false);

  const { toast } = useToast();

  // Load game session on mount
  useEffect(() => {
    const loadGame = async () => {
      try {
        const session = await staticGameService.getGame(gameCode);
        if (session) {
          setGameSession(session);
          const currentTeam = session.teams[session.currentTeamIndex];
          if (onTeamUpdate) {
            onTeamUpdate(currentTeam.name, currentTeam.score);
          }
          await loadQuestions();
        }
      } catch (error) {
        console.error('Failed to load game:', error);
        toast({
          title: "Error",
          description: "Failed to load game.",
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
      const [easy, hard] = await Promise.all([
        staticGameService.getRandomQuestion(gameCode, 'Easy'),
        staticGameService.getRandomQuestion(gameCode, 'Hard')
      ]);
      
      setEasyQuestion(easy);
      setHardQuestion(hard);
      // Keep the saved preference, don't reset to 'easy'
      setAnswerVisible(false);
    } catch (error) {
      console.error('Failed to load questions:', error);
      toast({
        title: "Error",
        description: "Failed to load questions.",
        variant: "destructive",
      });
    } finally {
      setLoadingQuestions(false);
    }
  };

  const handleAnswer = async (correct: boolean) => {
    if (!gameSession) return;

    const currentTeam = gameSession.teams[gameSession.currentTeamIndex];
    const points = correct ? (selectedTab === 'easy' ? 1 : 3) : 0;
    const currentQuestion = selectedTab === 'easy' ? easyQuestion : hardQuestion;

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
      questionHistory: currentQuestion ? [...gameSession.questionHistory, currentQuestion.id] : gameSession.questionHistory
    });

    setGameSession(updatedSession);

    // Update parent with new current team
    const newCurrentTeam = updatedTeams[nextTeamIndex];
    if (onTeamUpdate) {
      onTeamUpdate(newCurrentTeam.name, newCurrentTeam.score);
    }

    // Check for game end
    if (updatedTeam.score >= gameSession.targetScore) {
      await staticGameService.updateGame(gameCode, { gamePhase: 'ended' });
      setTimeout(onGameEnd, 500);
      return;
    }

    // Load next questions
    await loadQuestions();
  };


  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <div className="text-2xl font-bold mb-2">Loading Game...</div>
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
  const currentQuestion = selectedTab === 'easy' ? easyQuestion : hardQuestion;

  return (
    <div className="space-y-4">
      {/* Combined Card */}
      {!loadingQuestions && currentQuestion && (
        <div className="bg-white rounded-2xl p-6 shadow-sm">
            {/* Tabs Header */}
            <div className="mb-6">
              <Tabs value={selectedTab} onValueChange={(value) => {
                const difficulty = value as Difficulty;
                setSelectedTab(difficulty);
                localStorage.setItem('preferredDifficulty', difficulty);
              }} className="w-auto">
                <TabsList className="grid grid-cols-2 bg-gray-100 rounded-lg p-0.5">
                  <TabsTrigger value="easy" className="text-sm px-4 py-1.5 data-[state=active]:bg-white data-[state=active]:shadow-sm rounded-md">Easy</TabsTrigger>
                  <TabsTrigger value="hard" className="text-sm px-4 py-1.5 data-[state=active]:bg-white data-[state=active]:shadow-sm rounded-md">Hard</TabsTrigger>
                </TabsList>
              </Tabs>
            </div>

            {/* Team Standings - Expandable */}
            {teamsExpanded && (
              <div className="mb-6 space-y-2 border-t border-gray-100 pt-4">
                {gameSession.teams
                  .sort((a, b) => b.score - a.score)
                  .map((team) => (
                    <div
                      key={team.id}
                      className={`flex justify-between items-center p-3 rounded-lg ${
                        team.id === currentTeam.id
                          ? 'bg-blue-50 border border-blue-200'
                          : 'bg-gray-50'
                      }`}
                    >
                      <span className="font-medium text-gray-900">{team.name}</span>
                      <span className="text-gray-600">{team.score} points</span>
                    </div>
                  ))}
              </div>
            )}
            <Tabs value={selectedTab} onValueChange={(value) => {
              const difficulty = value as Difficulty;
              setSelectedTab(difficulty);
              localStorage.setItem('preferredDifficulty', difficulty);
            }}>
              <TabsList className="hidden">
                <TabsTrigger value="easy">Easy</TabsTrigger>
                <TabsTrigger value="hard">Hard</TabsTrigger>
              </TabsList>
              
              <TabsContent value={selectedTab} className="space-y-4 mt-0">
                <div className="text-lg leading-relaxed text-gray-900 py-4">
                  {currentQuestion.question}
                </div>

                <Button
                  onClick={() => setAnswerVisible(!answerVisible)}
                  variant="outline"
                  className="w-full border border-gray-200 hover:bg-gray-50 rounded-xl py-3"
                >
                  {answerVisible ? 'Hide answer' : 'Show answer'}
                </Button>

                {answerVisible && (
                  <div className="p-4 bg-gray-50 rounded-xl">
                    <div className="text-gray-900">{currentQuestion.answer}</div>
                    {currentQuestion.reference && (
                      <div className="text-sm text-gray-500 mt-2">
                        {currentQuestion.reference}
                      </div>
                    )}
                  </div>
                )}

                <div className="flex flex-col gap-3 pt-4">
                  <div className="flex flex-col sm:flex-row gap-3">
                    <Button
                      onClick={() => handleAnswer(true)}
                      className="bg-blue-500 hover:bg-blue-600 text-white w-full sm:flex-1 text-lg font-semibold py-4 rounded-xl transition-all duration-200"
                    >
                      Correct
                    </Button>
                    <Button
                      onClick={() => handleAnswer(false)}
                      className="bg-red-500 hover:bg-red-600 text-white w-full sm:flex-1 text-lg font-semibold py-4 rounded-xl transition-all duration-200"
                    >
                      Wrong
                    </Button>
                  </div>
                </div>
              </TabsContent>
            </Tabs>
        </div>
      )}

      {loadingQuestions && (
        <div className="bg-white rounded-2xl p-8 text-center shadow-sm">
          <div className="text-lg text-gray-500">Loading questions...</div>
        </div>
      )}
    </div>
  );
}