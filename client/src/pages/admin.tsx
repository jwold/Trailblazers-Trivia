import React, { useState, useEffect, useMemo } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Trash2, Edit, Plus, Save, X, ArrowLeft } from 'lucide-react';
import { Link } from 'wouter';

interface Question {
  id: number;
  question: string;
  answer: string;
  difficulty: string;
  reference: string;
  category: string;
}

interface NewQuestion {
  question: string;
  answer: string;
  difficulty: string;
  reference: string;
  category: string;
}

export function AdminPage() {
  // Static mode - show message instead of admin functionality
  return (
    <div className="container mx-auto p-8 max-w-2xl">
      <div className="text-center">
        <h1 className="text-3xl font-bold mb-4">Admin Panel</h1>
        <div className="bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-lg p-6">
          <h2 className="text-xl font-semibold mb-2">Static Mode</h2>
          <p className="text-gray-700 dark:text-gray-300">
            This app is running in static mode. Question editing is not available.
          </p>
          <p className="mt-2 text-sm text-gray-600 dark:text-gray-400">
            To edit questions, modify the JSON files in the <code className="bg-gray-100 dark:bg-gray-800 px-1 rounded">client/public/data</code> directory.
          </p>
        </div>
        <Link href="/">
          <Button className="mt-6">
            Back to Game
          </Button>
        </Link>
      </div>
    </div>
  );
}

// Original admin code below (disabled for static mode)
export function AdminPageDisabled() {
  const [questions, setQuestions] = useState<Question[]>([]);
  const [loading, setLoading] = useState(true);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [showAddForm, setShowAddForm] = useState(false);
  const [editForm, setEditForm] = useState<Question | null>(null);
  const [activeCategory, setActiveCategory] = useState<string>('bible');
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalQuestions, setTotalQuestions] = useState(0);
  const [availableCategories, setAvailableCategories] = useState<string[]>([]);
  const [categoryCounts, setCategoryCounts] = useState<Record<string, number>>({});
  const [updatingDifficulty, setUpdatingDifficulty] = useState<Set<number>>(new Set());
  const [newQuestion, setNewQuestion] = useState<NewQuestion>({
    question: '',
    answer: '',
    difficulty: 'Easy',
    reference: '',
    category: 'bible'
  });

  // Fetch paginated questions
  const fetchQuestions = async () => {
    try {
      setLoading(true);
      const params = new URLSearchParams({
        page: currentPage.toString(),
        limit: '200',
        ...(activeCategory && { category: activeCategory })
      });
      
      const response = await fetch(`/api/questions/paginated?${params}`);
      const data = await response.json();
      
      setQuestions(data.questions);
      setTotalPages(data.totalPages);
      setTotalQuestions(data.total);
    } catch (error) {
      console.error('Error fetching questions:', error);
    } finally {
      setLoading(false);
    }
  };

  // Fetch available categories and their counts
  const fetchCategories = async () => {
    try {
      const response = await fetch('/api/questions');
      const allQuestions = await response.json();
      const uniqueCategories = Array.from(new Set(allQuestions.map((q: Question) => q.category)));
      
      // Calculate counts for each category
      const counts: Record<string, number> = {};
      allQuestions.forEach((q: Question) => {
        counts[q.category] = (counts[q.category] || 0) + 1;
      });
      
      setAvailableCategories(uniqueCategories);
      setCategoryCounts(counts);
    } catch (error) {
      console.error('Error fetching categories:', error);
    }
  };

  useEffect(() => {
    fetchCategories();
  }, []);

  useEffect(() => {
    fetchQuestions();
  }, [currentPage, activeCategory]);

  // Handle category change
  const handleCategoryChange = (category: string) => {
    setActiveCategory(category);
    setCurrentPage(1); // Reset to first page when changing categories
  };

  // Handle page change
  const handlePageChange = (page: number) => {
    setCurrentPage(page);
  };

  // Toggle difficulty between Easy and Hard
  const handleDifficultyToggle = async (questionId: number, currentDifficulty: string) => {
    const newDifficulty = currentDifficulty === 'Easy' ? 'Hard' : 'Easy';
    
    // Add to updating set
    setUpdatingDifficulty(prev => new Set(prev).add(questionId));
    
    try {
      const question = questions.find(q => q.id === questionId);
      if (!question) return;

      const response = await fetch(`/api/admin/questions/${questionId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
          ...question,
          difficulty: newDifficulty 
        })
      });

      if (response.ok) {
        // Update the question in the local state
        setQuestions(prev => 
          prev.map(q => q.id === questionId ? { ...q, difficulty: newDifficulty } : q)
        );
      } else {
        const error = await response.json();
        alert('Error updating difficulty: ' + error.message);
      }
    } catch (error) {
      console.error('Error updating difficulty:', error);
      alert('Error updating difficulty');
    } finally {
      // Remove from updating set
      setUpdatingDifficulty(prev => {
        const newSet = new Set(prev);
        newSet.delete(questionId);
        return newSet;
      });
    }
  };



  // Add new question
  const handleAddQuestion = async () => {
    if (!newQuestion.question.trim() || !newQuestion.answer.trim()) {
      alert('Question and answer are required');
      return;
    }

    try {
      const response = await fetch('/api/admin/questions', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newQuestion)
      });

      if (response.ok) {
        setNewQuestion({
          question: '',
          answer: '',
          difficulty: 'Easy',
          reference: '',
          category: 'bible'
        });
        setShowAddForm(false);
        fetchQuestions();
      } else {
        const error = await response.json();
        alert('Error adding question: ' + error.message);
      }
    } catch (error) {
      console.error('Error adding question:', error);
      alert('Error adding question');
    }
  };

  // Update question
  const handleUpdateQuestion = async () => {
    if (!editForm) return;

    try {
      const response = await fetch(`/api/admin/questions/${editForm.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(editForm)
      });

      if (response.ok) {
        setEditingId(null);
        setEditForm(null);
        fetchQuestions();
      } else {
        const error = await response.json();
        alert('Error updating question: ' + error.message);
      }
    } catch (error) {
      console.error('Error updating question:', error);
      alert('Error updating question');
    }
  };

  // Delete question
  const handleDeleteQuestion = async (id: number) => {
    if (!confirm('Are you sure you want to delete this question?')) return;

    try {
      const response = await fetch(`/api/admin/questions/${id}`, {
        method: 'DELETE'
      });

      if (response.ok) {
        fetchQuestions();
      } else {
        const error = await response.json();
        alert('Error deleting question: ' + error.message);
      }
    } catch (error) {
      console.error('Error deleting question:', error);
      alert('Error deleting question');
    }
  };

  // Start editing
  const startEditing = (question: Question) => {
    // Use React.startTransition to make the edit mode switch non-blocking
    React.startTransition(() => {
      setEditingId(question.id);
      setEditForm({ ...question });
    });
  };

  // Cancel editing
  const cancelEditing = () => {
    React.startTransition(() => {
      setEditingId(null);
      setEditForm(null);
    });
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-900 via-purple-900 to-indigo-900 flex items-center justify-center">
        <div className="text-white text-xl">Loading questions...</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-900 via-purple-900 to-indigo-900 p-4">
      <div className="max-w-6xl mx-auto">
        <div className="text-center mb-8">
          <div className="flex items-center justify-center mb-4">
            <Link href="/">
              <Button variant="outline" className="mr-4 bg-white/10 text-white border-white/20 hover:bg-white/20">
                <ArrowLeft className="w-4 h-4 mr-2" />
                Back to Game
              </Button>
            </Link>
          </div>
          <h1 className="text-4xl font-bold text-white mb-2">Question Admin</h1>
          <p className="text-blue-200">Manage trivia questions</p>
        </div>

        {/* Admin Actions */}
        <div className="mb-6 flex gap-4 flex-wrap">
          <Button 
            onClick={() => setShowAddForm(!showAddForm)}
            className="bg-green-600 hover:bg-green-700"
          >
            <Plus className="w-4 h-4 mr-2" />
            Add New Question
          </Button>
        </div>


        {/* Add Question Form */}
        {showAddForm && (
          <Card className="mb-6">
            <CardHeader>
              <CardTitle>Add New Question</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <Label htmlFor="new-question">Question</Label>
                <Textarea
                  id="new-question"
                  value={newQuestion.question}
                  onChange={(e) => setNewQuestion({...newQuestion, question: e.target.value})}
                  placeholder="Enter the trivia question..."
                />
              </div>
              <div>
                <Label htmlFor="new-answer">Answer</Label>
                <Input
                  id="new-answer"
                  value={newQuestion.answer}
                  onChange={(e) => setNewQuestion({...newQuestion, answer: e.target.value})}
                  placeholder="Enter the correct answer..."
                />
              </div>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                  <Label htmlFor="new-difficulty">Difficulty</Label>
                  <Select 
                    value={newQuestion.difficulty} 
                    onValueChange={(value) => setNewQuestion({...newQuestion, difficulty: value})}
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="Easy">Easy</SelectItem>
                      <SelectItem value="Hard">Hard</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div>
                  <Label htmlFor="new-category">Category</Label>
                  <Select 
                    value={newQuestion.category} 
                    onValueChange={(value) => setNewQuestion({...newQuestion, category: value})}
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="bible">Bible</SelectItem>
                      <SelectItem value="general">General</SelectItem>
                      <SelectItem value="history">History</SelectItem>
                      <SelectItem value="science">Science</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div>
                  <Label htmlFor="new-reference">Reference</Label>
                  <Input
                    id="new-reference"
                    value={newQuestion.reference}
                    onChange={(e) => setNewQuestion({...newQuestion, reference: e.target.value})}
                    placeholder="Bible verse, source, etc."
                  />
                </div>
              </div>
              <div className="flex gap-2">
                <Button onClick={handleAddQuestion} className="bg-green-600 hover:bg-green-700">
                  <Save className="w-4 h-4 mr-2" />
                  Add Question
                </Button>
                <Button onClick={() => setShowAddForm(false)} variant="outline">
                  <X className="w-4 h-4 mr-2" />
                  Cancel
                </Button>
              </div>
            </CardContent>
          </Card>
        )}

        {/* Category Tabs */}
        <Tabs value={activeCategory} onValueChange={handleCategoryChange} className="mb-6">
          <TabsList className="grid w-full grid-cols-5 mb-6 bg-white/20">
            {availableCategories.map((category) => (
              <TabsTrigger 
                key={category} 
                value={category} 
                className="capitalize text-xs px-2 data-[state=active]:bg-blue-600 data-[state=active]:text-white data-[state=active]:font-bold data-[state=active]:shadow-lg text-white/80 hover:text-white/90"
              >
                {`${category.replace('_', ' ')} (${(categoryCounts[category] || 0).toLocaleString()})`}
              </TabsTrigger>
            ))}
          </TabsList>

          {/* Questions List */}
          <div className="space-y-4">
            {questions.map((question) => (
            <Card key={question.id} className="bg-white/90">
              <CardContent className="p-6">
                {editingId === question.id && editForm ? (
                  // Edit Form
                  <div className="space-y-4">
                    <div>
                      <Label>Question</Label>
                      <Textarea
                        value={editForm.question}
                        onChange={(e) => setEditForm({...editForm, question: e.target.value})}
                      />
                    </div>
                    <div>
                      <Label>Answer</Label>
                      <Input
                        value={editForm.answer}
                        onChange={(e) => setEditForm({...editForm, answer: e.target.value})}
                      />
                    </div>
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                      <div>
                        <Label>Difficulty</Label>
                        <Select 
                          value={editForm.difficulty} 
                          onValueChange={(value) => setEditForm({...editForm, difficulty: value})}
                        >
                          <SelectTrigger>
                            <SelectValue />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="Easy">Easy</SelectItem>
                            <SelectItem value="Hard">Hard</SelectItem>
                          </SelectContent>
                        </Select>
                      </div>
                      <div>
                        <Label>Category</Label>
                        <Select 
                          value={editForm.category} 
                          onValueChange={(value) => setEditForm({...editForm, category: value})}
                        >
                          <SelectTrigger>
                            <SelectValue />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="bible">Bible</SelectItem>
                            <SelectItem value="general">General</SelectItem>
                            <SelectItem value="history">History</SelectItem>
                            <SelectItem value="science">Science</SelectItem>
                          </SelectContent>
                        </Select>
                      </div>
                      <div>
                        <Label>Reference</Label>
                        <Input
                          value={editForm.reference}
                          onChange={(e) => setEditForm({...editForm, reference: e.target.value})}
                        />
                      </div>
                    </div>
                    <div className="flex gap-2">
                      <Button onClick={handleUpdateQuestion} className="bg-blue-600 hover:bg-blue-700">
                        <Save className="w-4 h-4 mr-2" />
                        Save Changes
                      </Button>
                      <Button onClick={cancelEditing} variant="outline">
                        <X className="w-4 h-4 mr-2" />
                        Cancel
                      </Button>
                    </div>
                  </div>
                ) : (
                  // Display Mode
                  <div>
                    <div className="flex justify-between items-start mb-4">
                      <div className="flex-1">
                        <h3 className="text-lg font-semibold mb-2">{question.question}</h3>
                        <p className="text-green-700 font-medium mb-2">Answer: {question.answer}</p>
                        <div className="flex gap-4 text-sm text-gray-600 items-center">
                          {/* Clickable Difficulty Badge */}
                          <button
                            onClick={() => handleDifficultyToggle(question.id, question.difficulty)}
                            disabled={updatingDifficulty.has(question.id)}
                            className={`px-2 py-1 rounded cursor-pointer transition-all duration-200 hover:scale-105 active:scale-95 disabled:cursor-not-allowed disabled:opacity-60 ${
                              question.difficulty === 'Easy' 
                                ? 'bg-blue-100 text-blue-800 hover:bg-blue-200' 
                                : 'bg-red-100 text-red-800 hover:bg-red-200'
                            }`}
                            title={`Click to change to ${question.difficulty === 'Easy' ? 'Hard' : 'Easy'}`}
                          >
                            <div className="flex items-center gap-1">
                              {question.difficulty}
                              {updatingDifficulty.has(question.id) && (
                                <div className="w-3 h-3 border border-current border-t-transparent rounded-full animate-spin"></div>
                              )}
                            </div>
                          </button>
                          
                          {question.reference && (
                            <span className="bg-gray-100 px-2 py-1 rounded">
                              {question.reference}
                            </span>
                          )}
                        </div>
                      </div>
                      <div className="flex gap-2 ml-4">
                        <Button 
                          onClick={() => startEditing(question)}
                          size="sm"
                          variant="outline"
                        >
                          <Edit className="w-4 h-4" />
                        </Button>
                        <Button 
                          onClick={() => handleDeleteQuestion(question.id)}
                          size="sm"
                          variant="destructive"
                        >
                          <Trash2 className="w-4 h-4" />
                        </Button>
                      </div>
                    </div>
                  </div>
                )}
              </CardContent>
            </Card>
          ))}
          </div>

          {questions.length === 0 && !loading && (
            <Card>
              <CardContent className="text-center py-12">
                <p className="text-gray-500 text-lg">
                  No questions found in the {activeCategory.replace('_', ' ')} category.
                </p>
              </CardContent>
            </Card>
          )}

          {/* Pagination */}
          {totalPages > 1 && (
            <div className="flex justify-center items-center gap-4 mt-8">
              <Button
                onClick={() => handlePageChange(currentPage - 1)}
                disabled={currentPage === 1}
                variant="outline"
                className="bg-white/10 text-white border-white/20 hover:bg-white/20"
              >
                Previous
              </Button>
              
              <div className="flex gap-2">
                {Array.from({ length: Math.min(totalPages, 7) }, (_, i) => {
                  let pageNumber;
                  if (totalPages <= 7) {
                    pageNumber = i + 1;
                  } else if (currentPage <= 4) {
                    pageNumber = i + 1;
                  } else if (currentPage >= totalPages - 3) {
                    pageNumber = totalPages - 6 + i;
                  } else {
                    pageNumber = currentPage - 3 + i;
                  }
                  
                  return (
                    <Button
                      key={pageNumber}
                      onClick={() => handlePageChange(pageNumber)}
                      variant={currentPage === pageNumber ? "default" : "outline"}
                      className={currentPage === pageNumber 
                        ? "bg-blue-600 text-white" 
                        : "bg-white/10 text-white border-white/20 hover:bg-white/20"
                      }
                      size="sm"
                    >
                      {pageNumber}
                    </Button>
                  );
                })}
              </div>
              
              <Button
                onClick={() => handlePageChange(currentPage + 1)}
                disabled={currentPage === totalPages}
                variant="outline"
                className="bg-white/10 text-white border-white/20 hover:bg-white/20"
              >
                Next
              </Button>
            </div>
          )}

          {/* Pagination Info */}
          <div className="text-center mt-4">
            <p className="text-white/80 text-sm">
              Showing {((currentPage - 1) * 200) + 1} to {Math.min(currentPage * 200, totalQuestions)} of {totalQuestions} questions
            </p>
          </div>
        </Tabs>
      </div>
    </div>
  );
}