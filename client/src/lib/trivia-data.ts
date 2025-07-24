// This file contains the trivia questions from the CSV data
// In a production environment, this would be loaded from the server

export interface TriviaQuestionData {
  id: number;
  difficulty: string;
  question: string;
  answer: string;
  reference: string;
}

export const triviaQuestions: TriviaQuestionData[] = [
  // Easy Questions
  { id: 1, difficulty: "Easy", question: "Who was the first man created by God?", answer: "Adam", reference: "Genesis 2:7" },
  { id: 2, difficulty: "Easy", question: "What did God create on the first day?", answer: "Light", reference: "Genesis 1:3" },
  { id: 3, difficulty: "Easy", question: "Who built an ark to survive the flood?", answer: "Noah", reference: "Genesis 6:14" },
  { id: 4, difficulty: "Easy", question: "What was the name of Abraham's son?", answer: "Isaac", reference: "Genesis 21:3" },
  { id: 5, difficulty: "Easy", question: "What sign did God give after the flood?", answer: "Rainbow", reference: "Genesis 9:13" },
  { id: 6, difficulty: "Easy", question: "Who was swallowed by a great fish?", answer: "Jonah", reference: "Jonah 1:17" },
  { id: 7, difficulty: "Easy", question: "How many days did it rain during the flood?", answer: "40 days and 40 nights", reference: "Genesis 7:12" },
  { id: 8, difficulty: "Easy", question: "Who was the strongest man in the Bible?", answer: "Samson", reference: "Judges 16:17" },
  { id: 9, difficulty: "Easy", question: "What did David use to defeat Goliath?", answer: "A sling and stone", reference: "1 Samuel 17:50" },
  { id: 10, difficulty: "Easy", question: "How many disciples did Jesus have?", answer: "12", reference: "Matthew 10:1-4" },

  // Medium Questions
  { id: 11, difficulty: "Medium", question: "Who interpreted Pharaoh's dreams about the famine?", answer: "Joseph", reference: "Genesis 41:15-16" },
  { id: 12, difficulty: "Medium", question: "What sea did Moses and the Israelites cross?", answer: "Red Sea", reference: "Exodus 14:21" },
  { id: 13, difficulty: "Medium", question: "Who led the Israelites into the Promised Land?", answer: "Joshua", reference: "Joshua 1:1-2" },
  { id: 14, difficulty: "Medium", question: "What food did God provide in the desert?", answer: "Manna", reference: "Exodus 16:15" },
  { id: 15, difficulty: "Medium", question: "Which woman became queen and saved her people?", answer: "Esther", reference: "Esther 4:14" },
  { id: 16, difficulty: "Medium", question: "Who was thrown into the lion's den?", answer: "Daniel", reference: "Daniel 6:16" },
  { id: 17, difficulty: "Medium", question: "What did Moses' staff turn into?", answer: "A serpent", reference: "Exodus 7:10" },
  { id: 18, difficulty: "Medium", question: "How many plagues did God send on Egypt?", answer: "10", reference: "Exodus 7-12" },
  { id: 19, difficulty: "Medium", question: "Who was the first king of Israel?", answer: "Saul", reference: "1 Samuel 10:1" },
  { id: 20, difficulty: "Medium", question: "What did Jesus multiply to feed 5000 people?", answer: "Five loaves and two fish", reference: "Matthew 14:17-21" },

  // Hard Questions
  { id: 21, difficulty: "Hard", question: "Who was the left-handed judge who killed King Eglon?", answer: "Ehud", reference: "Judges 3:15-21" },
  { id: 22, difficulty: "Hard", question: "What prophet saw a vision of a valley of dry bones?", answer: "Ezekiel", reference: "Ezekiel 37:1-10" },
  { id: 23, difficulty: "Hard", question: "Who was the prophet taken to heaven in a whirlwind?", answer: "Elijah", reference: "2 Kings 2:11" },
  { id: 24, difficulty: "Hard", question: "Which apostle survived a snake bite on Malta?", answer: "Paul", reference: "Acts 28:3-6" },
  { id: 25, difficulty: "Hard", question: "Who was the high priest when Samuel was a boy?", answer: "Eli", reference: "1 Samuel 1:9" },
  { id: 26, difficulty: "Hard", question: "What was the name of the mountain where Moses received the Ten Commandments?", answer: "Mount Sinai", reference: "Exodus 19:20" },
  { id: 27, difficulty: "Hard", question: "Who was the mother of John the Baptist?", answer: "Elizabeth", reference: "Luke 1:57-60" },
  { id: 28, difficulty: "Hard", question: "How many years did the Israelites wander in the wilderness?", answer: "40 years", reference: "Numbers 14:33" },
  { id: 29, difficulty: "Hard", question: "Who was the king of Babylon who conquered Jerusalem?", answer: "Nebuchadnezzar", reference: "2 Kings 25:1" },
  { id: 30, difficulty: "Hard", question: "What was the name of Abraham's nephew?", answer: "Lot", reference: "Genesis 12:5" },
];

export function getQuestionsByDifficulty(difficulty: string): TriviaQuestionData[] {
  return triviaQuestions.filter(q => q.difficulty.toLowerCase() === difficulty.toLowerCase());
}

export function getRandomQuestion(difficulty: string, excludeIds: number[] = []): TriviaQuestionData | null {
  const questions = getQuestionsByDifficulty(difficulty);
  const availableQuestions = questions.filter(q => !excludeIds.includes(q.id));
  
  if (availableQuestions.length === 0) return null;
  
  const randomIndex = Math.floor(Math.random() * availableQuestions.length);
  return availableQuestions[randomIndex];
}
