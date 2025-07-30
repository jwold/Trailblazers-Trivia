import { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
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
  const [questions, setQuestions] = useState<Question[]>([]);
  const [loading, setLoading] = useState(true);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [showAddForm, setShowAddForm] = useState(false);
  const [editForm, setEditForm] = useState<Question | null>(null);
  const [newQuestion, setNewQuestion] = useState<NewQuestion>({
    question: '',
    answer: '',
    difficulty: 'Easy',
    reference: '',
    category: 'bible'
  });

  // Fetch all questions
  const fetchQuestions = async () => {
    try {
      const response = await fetch('/api/questions');
      const data = await response.json();
      setQuestions(data);
    } catch (error) {
      console.error('Error fetching questions:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchQuestions();
  }, []);

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
    setEditingId(question.id);
    setEditForm({ ...question });
  };

  // Cancel editing
  const cancelEditing = () => {
    setEditingId(null);
    setEditForm(null);
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

        {/* Add Question Button */}
        <div className="mb-6">
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
                      <SelectItem value="Medium">Medium</SelectItem>
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
                            <SelectItem value="Medium">Medium</SelectItem>
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
                        <div className="flex gap-4 text-sm text-gray-600">
                          <span className="bg-blue-100 px-2 py-1 rounded">
                            {question.difficulty}
                          </span>
                          <span className="bg-purple-100 px-2 py-1 rounded">
                            {question.category}
                          </span>
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

        {questions.length === 0 && (
          <Card>
            <CardContent className="text-center py-12">
              <p className="text-gray-500 text-lg">No questions found. Add some questions to get started!</p>
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  );
}