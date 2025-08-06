/**
 * Debug script for Trailblazers Trivia static site
 * Copy and paste this into the browser console to debug the blank screen issue
 */

(function debugTrivia() {
  console.log('🐛 Starting Trailblazers Trivia Debug...');
  
  // 1. Check if React root element exists
  const rootElement = document.getElementById('root');
  console.log('✅ Root element found:', !!rootElement);
  console.log('Root element content length:', rootElement?.innerHTML.length || 0);
  
  // 2. Check base path configuration
  console.log('📁 Base URL from import.meta.env:', window.location.pathname.includes('/Trailblazers-Trivia/') ? '/Trailblazers-Trivia/' : '/');
  console.log('📁 Current URL:', window.location.href);
  
  // 3. Test manifest loading
  async function testManifestLoading() {
    console.log('🧪 Testing manifest loading...');
    
    const basePath = window.location.pathname.includes('/Trailblazers-Trivia/') ? '/Trailblazers-Trivia/' : '/';
    const manifestUrl = `${basePath}data/manifest.json`;
    
    try {
      console.log('📥 Attempting to load manifest from:', manifestUrl);
      const response = await fetch(manifestUrl);
      console.log('✅ Manifest response status:', response.status);
      
      if (response.ok) {
        const manifest = await response.json();
        console.log('✅ Manifest loaded successfully:', manifest);
        return manifest;
      } else {
        console.error('❌ Manifest loading failed:', response.statusText);
        return null;
      }
    } catch (error) {
      console.error('❌ Manifest loading error:', error);
      return null;
    }
  }
  
  // 4. Test question data loading
  async function testQuestionLoading(category = 'bible', difficulty = 'easy') {
    console.log(`🧪 Testing ${category}-${difficulty} question loading...`);
    
    const basePath = window.location.pathname.includes('/Trailblazers-Trivia/') ? '/Trailblazers-Trivia/' : '/';
    const questionUrl = `${basePath}data/${category}-${difficulty}.json`;
    
    try {
      console.log('📥 Attempting to load questions from:', questionUrl);
      const response = await fetch(questionUrl);
      console.log(`✅ Questions response status for ${category}-${difficulty}:`, response.status);
      
      if (response.ok) {
        const questions = await response.json();
        console.log(`✅ Questions loaded successfully for ${category}-${difficulty}:`, questions.length, 'questions');
        return questions;
      } else {
        console.error(`❌ Questions loading failed for ${category}-${difficulty}:`, response.statusText);
        return null;
      }
    } catch (error) {
      console.error(`❌ Questions loading error for ${category}-${difficulty}:`, error);
      return null;
    }
  }
  
  // 5. Check localStorage state
  function checkLocalStorage() {
    console.log('💾 Checking localStorage...');
    const currentGame = localStorage.getItem('currentGame');
    const usedQuestions = localStorage.getItem('usedQuestions');
    
    console.log('Current game in localStorage:', currentGame ? JSON.parse(currentGame) : null);
    console.log('Used questions in localStorage:', usedQuestions ? JSON.parse(usedQuestions) : null);
  }
  
  // 6. Check for JavaScript errors
  function checkConsoleErrors() {
    console.log('🚨 Recent console errors (check the Console tab for full details):');
    // This is just a reminder to check the console manually
  }
  
  // 7. Test static game service
  async function testStaticGameService() {
    console.log('🎮 Testing static game service...');
    
    // Check if the service exists in the global scope
    if (window.staticGameService) {
      console.log('✅ Static game service found in global scope');
    } else {
      console.log('❌ Static game service NOT found in global scope');
    }
    
    // Try to simulate game creation
    try {
      console.log('🧪 Attempting to simulate game setup...');
      // This would normally be done through the React components
    } catch (error) {
      console.error('❌ Game service error:', error);
    }
  }
  
  // Run all tests
  async function runAllTests() {
    console.log('🚀 Running all debug tests...');
    console.log('================================');
    
    checkConsoleErrors();
    checkLocalStorage();
    
    const manifest = await testManifestLoading();
    
    if (manifest) {
      // Test loading questions for each category
      for (const category of manifest.categories) {
        await testQuestionLoading(category, 'easy');
        await testQuestionLoading(category, 'hard');
      }
    }
    
    await testStaticGameService();
    
    console.log('================================');
    console.log('🏁 Debug tests complete!');
    console.log('🔍 Check the console output above for any errors or issues.');
    console.log('💡 Common issues to check:');
    console.log('   - 404 errors when loading data files');
    console.log('   - Base path configuration issues');
    console.log('   - JavaScript errors preventing React from rendering');
    console.log('   - Network errors blocking resource loading');
  }
  
  // Start the debug process
  runAllTests();
})();