import fs from 'fs';
import path from 'path';
import { db } from '../server/db';
import { triviaQuestions } from '../shared/schema';
import { eq } from 'drizzle-orm';

interface CSVQuestion {
  id: string;
  difficulty: string;
  question: string;
  answer: string;
  reference: string;
}

async function importCSVQuestions() {
  try {
    console.log('Starting CSV import process...');
    
    // Read the CSV file
    const csvPath = path.join(process.cwd(), 'attached_assets', 'Database - Data2_1753374334320.csv');
    const csvContent = fs.readFileSync(csvPath, 'utf-8');
    
    // Parse CSV content
    const lines = csvContent.split('\n');
    const headers = lines[0].split(',').map(h => h.replace(/"/g, '').trim());
    
    console.log('Headers found:', headers);
    console.log(`Processing ${lines.length - 1} rows...`);
    
    const questionsToImport: any[] = [];
    let skippedCount = 0;
    let processedCount = 0;
    
    for (let i = 1; i < lines.length; i++) {
      const line = lines[i].trim();
      if (!line) continue;
      
      // Parse CSV line with proper handling of quoted fields
      const fields = parseCSVLine(line);
      if (fields.length < 5) {
        console.log(`Skipping line ${i}: insufficient fields`);
        skippedCount++;
        continue;
      }
      
      const [id, difficulty, question, answer, reference] = fields;
      
      // Skip if missing critical data
      if (!question?.trim() || !answer?.trim()) {
        console.log(`Skipping line ${i}: missing question or answer`);
        skippedCount++;
        continue;
      }
      
      // Normalize difficulty
      let normalizedDifficulty = difficulty.trim();
      if (normalizedDifficulty === 'Difficult') {
        normalizedDifficulty = 'Hard';
      }
      
      // Validate difficulty
      if (!['Easy', 'Hard'].includes(normalizedDifficulty)) {
        console.log(`Skipping line ${i}: invalid difficulty "${difficulty}"`);
        skippedCount++;
        continue;
      }
      
      questionsToImport.push({
        difficulty: normalizedDifficulty as 'Easy' | 'Hard',
        question: question.trim().replace(/^"|"$/g, ''), // Remove surrounding quotes
        answer: answer.trim().replace(/^"|"$/g, ''),
        reference: reference?.trim().replace(/^"|"$/g, '') || ''
      });
      
      processedCount++;
    }
    
    console.log(`Processed: ${processedCount}, Skipped: ${skippedCount}`);
    console.log(`Ready to import ${questionsToImport.length} questions`);
    
    // Clear existing questions first
    console.log('Clearing existing questions...');
    await db.delete(triviaQuestions);
    
    // Insert new questions in batches
    const batchSize = 50;
    let importedCount = 0;
    
    for (let i = 0; i < questionsToImport.length; i += batchSize) {
      const batch = questionsToImport.slice(i, i + batchSize);
      await db.insert(triviaQuestions).values(batch);
      importedCount += batch.length;
      console.log(`Imported batch: ${importedCount}/${questionsToImport.length}`);
    }
    
    // Get final counts by difficulty
    const easyCounts = await db.select().from(triviaQuestions).where(eq(triviaQuestions.difficulty, 'Easy'));
    const hardCounts = await db.select().from(triviaQuestions).where(eq(triviaQuestions.difficulty, 'Hard'));
    
    console.log('\n✅ Import completed successfully!');
    console.log(`📊 Final database stats:`);
    console.log(`   Easy questions: ${easyCounts.length}`);
    console.log(`   Hard questions: ${hardCounts.length}`);
    console.log(`   Total questions: ${easyCounts.length + hardCounts.length}`);
    
  } catch (error) {
    console.error('❌ Error importing CSV:', error);
    process.exit(1);
  }
}

// Helper function to parse CSV line with proper quote handling
function parseCSVLine(line: string): string[] {
  const fields: string[] = [];
  let current = '';
  let inQuotes = false;
  let i = 0;
  
  while (i < line.length) {
    const char = line[i];
    
    if (char === '"') {
      if (inQuotes && line[i + 1] === '"') {
        // Escaped quote
        current += '"';
        i += 2;
      } else {
        // Toggle quote state
        inQuotes = !inQuotes;
        i++;
      }
    } else if (char === ',' && !inQuotes) {
      // Field separator
      fields.push(current);
      current = '';
      i++;
    } else {
      current += char;
      i++;
    }
  }
  
  // Add the last field
  fields.push(current);
  
  return fields;
}

// Run the import
importCSVQuestions().then(() => {
  console.log('Script completed');
  process.exit(0);
}).catch((error) => {
  console.error('Script failed:', error);
  process.exit(1);
});