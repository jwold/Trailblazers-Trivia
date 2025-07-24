import { db } from "../server/db";
import { triviaQuestions } from "@shared/schema";
import fs from "fs";
import path from "path";

interface CSVRow {
  id: string;
  difficulty: string;
  question: string;
  answer: string;
  reference: string;
}

async function loadQuestionsFromCSV() {
  try {
    console.log("Loading questions from CSV...");
    
    // Read the CSV file
    const csvPath = path.join(process.cwd(), "attached_assets", "Curated_Bible_Trivia_Questions__500_Real_Format__1753327262938.csv");
    const csvContent = fs.readFileSync(csvPath, "utf-8");
    
    // Parse CSV (skip header)
    const lines = csvContent.trim().split("\n");
    const headers = lines[0].split(",");
    
    console.log(`Found ${lines.length - 1} questions to load...`);
    
    // Clear existing questions
    await db.delete(triviaQuestions);
    console.log("Cleared existing questions");
    
    // Parse and insert questions in batches
    const batchSize = 50;
    const questions = [];
    
    for (let i = 1; i < lines.length; i++) {
      const line = lines[i];
      if (!line.trim()) continue;
      
      // Simple CSV parsing (handles basic cases)
      const values = line.split(",");
      if (values.length < 5) continue;
      
      const question = {
        difficulty: values[1].trim(),
        question: values[2].trim(),
        answer: values[3].trim(),
        reference: values[4].trim(),
      };
      
      // Validate required fields
      if (question.difficulty && question.question && question.answer && question.reference) {
        questions.push(question);
      }
    }
    
    console.log(`Parsed ${questions.length} valid questions`);
    
    // Insert questions in batches
    for (let i = 0; i < questions.length; i += batchSize) {
      const batch = questions.slice(i, i + batchSize);
      await db.insert(triviaQuestions).values(batch);
      console.log(`Inserted batch ${Math.floor(i / batchSize) + 1}/${Math.ceil(questions.length / batchSize)}`);
    }
    
    // Verify the count
    const count = await db.select().from(triviaQuestions);
    console.log(`Successfully loaded ${count.length} questions into the database`);
    
    // Show difficulty breakdown
    const easyCount = count.filter(q => q.difficulty === "Easy").length;
    const mediumCount = count.filter(q => q.difficulty === "Medium").length;
    const hardCount = count.filter(q => q.difficulty === "Hard").length;
    
    console.log(`Difficulty breakdown:`);
    console.log(`- Easy: ${easyCount}`);
    console.log(`- Medium: ${mediumCount}`);
    console.log(`- Hard: ${hardCount}`);
    
  } catch (error) {
    console.error("Error loading questions:", error);
    process.exit(1);
  }
}

// Run the script
loadQuestionsFromCSV().then(() => {
  console.log("Questions loaded successfully!");
  process.exit(0);
}).catch((error) => {
  console.error("Failed to load questions:", error);
  process.exit(1);
});