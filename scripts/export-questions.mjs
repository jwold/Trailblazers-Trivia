import Database from 'better-sqlite3';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Connect to the database
const db = new Database('trivia.db', { readonly: true });

// Query all questions
const questions = db.prepare(`
  SELECT id, question, answer, difficulty, reference, category 
  FROM trivia_questions 
  ORDER BY category, difficulty, id
`).all();

// Group questions by category and difficulty
const groupedQuestions = {};

questions.forEach(q => {
  const category = q.category || 'bible';
  const difficulty = q.difficulty || 'Easy';
  
  if (!groupedQuestions[category]) {
    groupedQuestions[category] = {
      Easy: [],
      Hard: []
    };
  }
  
  groupedQuestions[category][difficulty].push({
    id: q.id,
    question: q.question,
    answer: q.answer,
    reference: q.reference
  });
});

// Write JSON files for each category/difficulty combination
const outputDir = path.join(__dirname, '..', 'client', 'public', 'data');

Object.entries(groupedQuestions).forEach(([category, difficulties]) => {
  Object.entries(difficulties).forEach(([difficulty, questions]) => {
    const filename = `${category}-${difficulty.toLowerCase()}.json`;
    const filepath = path.join(outputDir, filename);
    
    fs.writeFileSync(filepath, JSON.stringify(questions, null, 2));
    console.log(`Exported ${questions.length} ${difficulty} questions to ${filename}`);
  });
});

// Create a manifest file
const manifest = {
  categories: Object.keys(groupedQuestions),
  totalQuestions: questions.length,
  questionCounts: {}
};

Object.entries(groupedQuestions).forEach(([category, difficulties]) => {
  manifest.questionCounts[category] = {
    easy: difficulties.Easy.length,
    hard: difficulties.Hard.length,
    total: difficulties.Easy.length + difficulties.Hard.length
  };
});

fs.writeFileSync(
  path.join(outputDir, 'manifest.json'), 
  JSON.stringify(manifest, null, 2)
);

console.log('\nTotal questions exported:', questions.length);
console.log('Manifest created at data/manifest.json');

db.close();