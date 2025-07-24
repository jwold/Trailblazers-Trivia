export function createConfetti() {
  const container = document.getElementById('confetti-container');
  if (!container) return;
  
  const colors = ['#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#F97316'];
  
  for (let i = 0; i < 50; i++) {
    const confetti = document.createElement('div');
    confetti.className = 'confetti fixed w-2 h-2 rounded-full pointer-events-none';
    confetti.style.backgroundColor = colors[Math.floor(Math.random() * colors.length)];
    confetti.style.left = Math.random() * 100 + '%';
    confetti.style.animationDelay = Math.random() * 3 + 's';
    confetti.style.animationDuration = (Math.random() * 2 + 2) + 's';
    confetti.style.zIndex = '9999';
    
    container.appendChild(confetti);
    
    setTimeout(() => {
      if (container.contains(confetti)) {
        container.removeChild(confetti);
      }
    }, 5000);
  }
}

export function createEncouragement(message: string) {
  // Create a temporary toast-like element for encouragement
  const encouragement = document.createElement('div');
  encouragement.className = 'fixed top-20 left-1/2 transform -translate-x-1/2 bg-green-500 text-white px-6 py-3 rounded-full font-bold text-lg z-50 animate-bounce';
  encouragement.textContent = message;
  encouragement.style.zIndex = '9999';
  
  document.body.appendChild(encouragement);
  
  setTimeout(() => {
    if (document.body.contains(encouragement)) {
      document.body.removeChild(encouragement);
    }
  }, 3000);
}

export function generateHint(question: string, reference: string): string {
  // Simple hint generation based on reference
  const book = reference.split(' ')[0];
  return `Look in the book of ${book} for the answer to this question.`;
}

export function calculateScore(difficulty: string): number {
  switch (difficulty.toLowerCase()) {
    case 'easy':
      return 1;
    case 'hard':
      return 2;
    default:
      return 1;
  }
}

export function formatTime(seconds: number): string {
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return `${mins}:${secs.toString().padStart(2, '0')}`;
}

export function shuffleArray<T>(array: T[]): T[] {
  const shuffled = [...array];
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
  }
  return shuffled;
}
