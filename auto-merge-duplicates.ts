import Database from 'better-sqlite3';

const sqlite = new Database('./trivia.db');

// Find and auto-merge all duplicates
async function autoMergeAllDuplicates() {
  console.log('🔍 Scanning for duplicate questions...');
  
  // Get all questions
  const allQuestions = sqlite.prepare('SELECT * FROM trivia_questions').all();
  console.log(`📊 Total questions: ${allQuestions.length}`);
  
  // Function to normalize question text for comparison
  const normalizeQuestion = (text: string): string => {
    return text
      .toLowerCase()
      .replace(/[^\w\s]/g, '') // Remove punctuation
      .replace(/\s+/g, ' ')     // Normalize whitespace
      .trim();
  };
  
  // Group questions by normalized text
  const questionGroups: Map<string, any[]> = new Map();
  
  allQuestions.forEach(question => {
    const normalized = normalizeQuestion(question.question);
    if (!questionGroups.has(normalized)) {
      questionGroups.set(normalized, []);
    }
    questionGroups.get(normalized)!.push(question);
  });
  
  // Find groups with more than one question (duplicates)
  const duplicateGroups: any[] = [];
  questionGroups.forEach((questions, normalizedText) => {
    if (questions.length > 1) {
      duplicateGroups.push({
        question: questions[0].question,
        duplicates: questions.sort((a, b) => a.id - b.id)
      });
    }
  });
  
  console.log(`🔍 Found ${duplicateGroups.length} duplicate groups`);
  
  if (duplicateGroups.length === 0) {
    console.log('🎉 No duplicates found! Database is clean.');
    return;
  }
  
  // Auto-merge all duplicate groups
  let totalMerged = 0;
  let totalDeleted = 0;
  
  for (const group of duplicateGroups) {
    const questions = group.duplicates;
    console.log(`\n📝 Processing group: "${group.question}" (${questions.length} copies)`);
    
    // Choose the "best" question to keep (prefer one with reference, then lowest ID)
    const bestQuestion = questions.reduce((best, current) => {
      // Prefer question with reference
      if (current.reference && !best.reference) return current;
      if (!current.reference && best.reference) return best;
      
      // If both have references or both don't, prefer lower ID (older question)
      return current.id < best.id ? current : best;
    });
    
    console.log(`  ✅ Keeping question ID ${bestQuestion.id} (${bestQuestion.reference ? 'has reference' : 'no reference'})`);
    
    // Delete all other questions
    const toDelete = questions.filter(q => q.id !== bestQuestion.id);
    const deleteStmt = sqlite.prepare('DELETE FROM trivia_questions WHERE id = ?');
    
    for (const question of toDelete) {
      deleteStmt.run(question.id);
      console.log(`  🗑️ Deleted question ID ${question.id}`);
      totalDeleted++;
    }
    
    totalMerged++;
  }
  
  console.log(`\n🎉 Auto-merge complete!`);
  console.log(`📊 Groups merged: ${totalMerged}`);
  console.log(`🗑️ Questions deleted: ${totalDeleted}`);
  
  // Final count
  const finalCount = sqlite.prepare('SELECT COUNT(*) as count FROM trivia_questions').get() as { count: number };
  console.log(`📊 Final question count: ${finalCount.count}`);
}

// Run the auto-merge
autoMergeAllDuplicates()
  .then(() => {
    sqlite.close();
    console.log('✅ Database closed');
  })
  .catch((error) => {
    console.error('❌ Error:', error);
    sqlite.close();
    process.exit(1);
  });