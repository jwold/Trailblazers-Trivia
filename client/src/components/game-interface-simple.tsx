import { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useToast } from "@/hooks/use-toast";
import { type TriviaQuestion, type ClientGameSession, staticGameService } from "@/services/static-game-service";

interface GameInterfaceProps {
  gameCode: string;
  onGameEnd: () => void;
}

type Difficulty = "easy" | "hard";

export default function GameInterface({ gameCode, onGameEnd }: GameInterfaceProps) {
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

    // Check for game end
    if (updatedTeam.score >= gameSession.targetScore) {
      await staticGameService.updateGame(gameCode, { gamePhase: 'ended' });
      setTimeout(onGameEnd, 500);
      return;
    }

    // Load next questions
    await loadQuestions();
  };

  const handleSkip = async () => {
    if (!gameSession) return;

    // Just move to next team without scoring
    const nextTeamIndex = (gameSession.currentTeamIndex + 1) % gameSession.teams.length;
    
    const updatedSession = await staticGameService.updateGame(gameCode, {
      currentTeamIndex: nextTeamIndex
    });

    setGameSession(updatedSession);
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
        <Card className="border-4 border-gray-300">
          <CardContent className="p-6">
            {/* Player Info and Tabs Header */}
            <div className="flex items-start justify-between mb-6">
              <div 
                className="cursor-pointer hover:bg-gray-50 rounded-lg p-2 -m-2 transition-colors"
                onClick={() => setTeamsExpanded(!teamsExpanded)}
              >
                <h2 className="text-2xl font-bold text-gray-900">{currentTeam.name}'s turn</h2>
                <p className="text-sm text-gray-700">
                  {currentTeam.score}/{gameSession.targetScore} points
                </p>
              </div>
              
              <Tabs value={selectedTab} onValueChange={(value) => {
                const difficulty = value as Difficulty;
                setSelectedTab(difficulty);
                localStorage.setItem('preferredDifficulty', difficulty);
              }} className="w-auto">
                <TabsList className="grid grid-cols-2 h-8">
                  <TabsTrigger value="easy" className="text-xs px-3 py-1">Easy</TabsTrigger>
                  <TabsTrigger value="hard" className="text-xs px-3 py-1">Hard</TabsTrigger>
                </TabsList>
              </Tabs>
            </div>

            {/* Team Standings - Expandable */}
            {teamsExpanded && (
              <div className="mb-6 space-y-2 border-t-2 border-gray-200 pt-4">
                {gameSession.teams
                  .sort((a, b) => b.score - a.score)
                  .map((team) => (
                    <div 
                      key={team.id} 
                      className={`flex justify-between items-center p-3 rounded-lg ${
                        team.id === currentTeam.id 
                          ? 'bg-gray-200' 
                          : 'bg-gray-50'
                      }`}
                    >
                      <span className="font-medium text-gray-900">{team.name}</span>
                      <span className="text-gray-700">{team.score} points</span>
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
              
              <TabsContent value={selectedTab} className="space-y-4">
                <div className="text-xl font-medium leading-relaxed text-gray-900">
                  {currentQuestion.question}
                </div>

                <Button
                  onClick={() => setAnswerVisible(!answerVisible)}
                  variant="outline"
                  className="w-full border-2 border-gray-300 hover:bg-gray-100"
                >
                  {answerVisible ? 'Hide answer' : 'Show answer'}
                </Button>

                {answerVisible && (
                  <div className="p-4 bg-gray-100 rounded-lg border-2 border-gray-300">
                    <div className="text-gray-900">{currentQuestion.answer}</div>
                    {currentQuestion.reference && (
                      <div className="text-sm text-gray-700 mt-2">
                        {currentQuestion.reference}
                      </div>
                    )}
                  </div>
                )}

                <div className="flex flex-col gap-3 pt-4">
                  <div className="flex gap-3">
                    <Button
                      onClick={() => handleAnswer(true)}
                      className="bg-gradient-to-r from-blue-600 to-blue-800 text-white hover:from-blue-700 hover:to-blue-900 transition-all duration-200 border-4 border-blue-400 flex-1 text-[30px] font-bold pt-[32px] pb-[32px]"
                    >
                      Correct
                    </Button>
                    <Button
                      onClick={() => handleAnswer(false)}
                      className="bg-gradient-to-r from-gray-600 to-gray-800 text-white hover:from-gray-700 hover:to-gray-900 transition-all duration-200 border-4 border-gray-400 flex-1 text-[30px] font-bold pt-[32px] pb-[32px]"
                    >
                      Wrong
                    </Button>
                  </div>
                  <Button
                    onClick={handleSkip}
                    className="bg-gray-500 hover:bg-gray-600 text-white transition-all duration-200 text-sm py-2 w-32 mx-auto"
                  >
                    Skip Question
                  </Button>
                </div>
              </TabsContent>
            </Tabs>
          </CardContent>
        </Card>
      )}

      {loadingQuestions && (
        <Card className="border-4 border-gray-300">
          <CardContent className="p-8 text-center">
            <div className="text-xl text-gray-900">Loading questions...</div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}