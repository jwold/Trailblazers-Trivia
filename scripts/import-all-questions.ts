import Database from 'better-sqlite3';
import * as fs from 'fs';
import * as path from 'path';

const sqlite = new Database('./trivia.db');

interface Question {
  difficulty: string;
  question: string;
  answer: string;
  reference: string;
  category: string;
}

function parseCSV(content: string, hasHeader: boolean = true): Question[] {
  const lines = content.split('\n').filter(line => line.trim());
  
  if (lines.length === 0) return [];
  
  let headers: string[];
  let dataLines: string[];
  
  if (hasHeader) {
    headers = lines[0].split(',').map(h => h.trim().replace(/^"|"$/g, ''));
    dataLines = lines.slice(1);
  } else {
    // Assume standard format: id, difficulty, question, answer, reference, category
    headers = ['id', 'difficulty', 'question', 'answer', 'reference', 'category'];
    dataLines = lines;
  }
  
  return dataLines.map(line => {
    // Split CSV line while handling quoted values
    const values: string[] = [];
    let current = '';
    let inQuotes = false;
    
    for (let i = 0; i < line.length; i++) {
      const char = line[i];
      if (char === '"') {
        inQuotes = !inQuotes;
      } else if (char === ',' && !inQuotes) {
        values.push(current.trim());
        current = '';
      } else {
        current += char;
      }
    }
    values.push(current.trim()); // Add the last value
    
    const question: any = {};
    headers.forEach((header, index) => {
      question[header] = values[index] || '';
    });
    
    return {
      difficulty: question.difficulty || 'Medium',
      question: question.question || '',
      answer: question.answer || '',
      reference: question.reference || '',
      category: question.category || 'general'
    };
  }).filter(q => q.question && q.answer);
}

async function importAllQuestions() {
  try {
    console.log("🔄 Importing questions from CSV files...");
    
    const insertStmt = sqlite.prepare(`
      INSERT OR IGNORE INTO trivia_questions (difficulty, question, answer, reference, category)
      VALUES (?, ?, ?, ?, ?)
    `);
    
    let totalImported = 0;
    
    // Bible questions
    const bibleFiles = [
      'attached_assets/Curated_Bible_Trivia_Questions__500_Real_Format__1753327262938.csv',
      'attached_assets/Database - Data2_1753374334320.csv',
      'attached_assets/Deduplicated_Bible_Trivia_Questions_1753333349707.csv'
    ];
    
    for (const file of bibleFiles) {
      if (fs.existsSync(file)) {
        console.log(`📖 Processing ${path.basename(file)}...`);
        const content = fs.readFileSync(file, 'utf-8');
        const questions = parseCSV(content);
        
        for (const q of questions) {
          try {
            insertStmt.run(q.difficulty, q.question, q.answer, q.reference, 'bible');
            totalImported++;
          } catch (error) {
            // Skip duplicates
          }
        }
        console.log(`   ✅ Added ${questions.length} bible questions`);
      }
    }
    
    // Animal questions
    if (fs.existsSync('attached_assets/animal_questions.csv')) {
      console.log(`🦁 Processing animal_questions.csv...`);
      const content = fs.readFileSync('attached_assets/animal_questions.csv', 'utf-8');
      const questions = parseCSV(content, true); // Has header
      
      for (const q of questions) {
        try {
          insertStmt.run(q.difficulty, q.question, q.answer, q.reference, 'animals');
          totalImported++;
        } catch (error) {
          // Skip duplicates
        }
      }
      console.log(`   ✅ Added ${questions.length} animal questions`);
    }
    
    // US History questions  
    if (fs.existsSync('attached_assets/us_history_batch_1.csv')) {
      console.log(`🇺🇸 Processing us_history_batch_1.csv...`);
      const content = fs.readFileSync('attached_assets/us_history_batch_1.csv', 'utf-8');
      const questions = parseCSV(content, false); // No header
      
      for (const q of questions) {
        try {
          insertStmt.run(q.difficulty, q.question, q.answer, q.reference, 'us_history');
          totalImported++;
        } catch (error) {
          // Skip duplicates
        }
      }
      console.log(`   ✅ Added ${questions.length} US history questions`);
    }

    // Additional category files
    const categoryFiles = [
      { file: 'attached_assets/Pasted--id-difficulty-question-answer-reference-category-3001-Easy-Who-was-the-first-Presid-1753415949892_1753415949892.txt', name: 'us_history', icon: '🇺🇸' },
      { file: 'attached_assets/Pasted--id-difficulty-question-answer-reference-category-4001-Easy-Which-ancient-wonder-was-1753416166574_1753416166574.txt', name: 'world_history', icon: '🏛️' },
      { file: 'attached_assets/Pasted--id-difficulty-question-answer-reference-category-5001-Easy-What-is-the-largest-cont-1753416382449_1753416382449.txt', name: 'geography', icon: '🌍' },
    ];

    for (const categoryFile of categoryFiles) {
      if (fs.existsSync(categoryFile.file)) {
        console.log(`${categoryFile.icon} Processing ${categoryFile.name} questions...`);
        const content = fs.readFileSync(categoryFile.file, 'utf-8');
        const questions = parseCSV(content, true); // Has header
        
        for (const q of questions) {
          try {
            insertStmt.run(q.difficulty, q.question, q.answer, q.reference, q.category || categoryFile.name);
            totalImported++;
          } catch (error) {
            // Skip duplicates
          }
        }
        console.log(`   ✅ Added ${questions.length} ${categoryFile.name} questions`);
      }
    }
    
    // Check final count
    const totalCount = sqlite.prepare('SELECT COUNT(*) as count FROM trivia_questions').get() as { count: number };
    
    console.log(`✅ Import complete! Total questions in database: ${totalCount.count}`);
    
  } catch (error) {
    console.error("❌ Import failed:", error);
    throw error;
  } finally {
    sqlite.close();
  }
}

importAllQuestions();