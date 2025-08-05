import React, { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Save, X } from 'lucide-react';
import { useToast } from '@/hooks/use-toast';

interface Question {
  id: number;
  question: string;
  answer: string;
  difficulty: string;
  reference: string;
  category: string;
}

interface QuestionEditModalProps {
  question: Question | null;
  isOpen: boolean;
  onClose: () => void;
  onSave?: (updatedQuestion: Question) => void;
}

export function QuestionEditModal({ question, isOpen, onClose, onSave }: QuestionEditModalProps) {
  const [editForm, setEditForm] = useState<Question | null>(null);
  const [saving, setSaving] = useState(false);
  const { toast } = useToast();

  // Initialize form when question changes
  useEffect(() => {
    if (question) {
      setEditForm({ ...question });
    }
  }, [question]);

  const handleSave = async () => {
    if (!editForm) return;

    setSaving(true);
    try {
      const response = await fetch(`/api/admin/questions/${editForm.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(editForm)
      });

      if (response.ok) {
        const updatedQuestion = await response.json();
        toast({
          title: "Success",
          description: "Question updated successfully",
        });
        
        // Call onSave callback if provided
        if (onSave) {
          onSave(updatedQuestion.question || editForm);
        }
        
        onClose();
      } else {
        const error = await response.json();
        toast({
          title: "Error",
          description: error.message || "Failed to update question",
          variant: "destructive",
        });
      }
    } catch (error) {
      console.error('Error updating question:', error);
      toast({
        title: "Error", 
        description: "Failed to update question",
        variant: "destructive",
      });
    } finally {
      setSaving(false);
    }
  };

  const handleCancel = () => {
    setEditForm(question ? { ...question } : null);
    onClose();
  };

  if (!editForm) return null;

  return (
    <Dialog open={isOpen} onOpenChange={handleCancel}>
      <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Edit Question</DialogTitle>
        </DialogHeader>
        
        <div className="space-y-4">
          <div>
            <Label htmlFor="edit-question">Question</Label>
            <Textarea
              id="edit-question"
              value={editForm.question}
              onChange={(e) => setEditForm({ ...editForm, question: e.target.value })}
              className="min-h-[100px]"
            />
          </div>
          
          <div>
            <Label htmlFor="edit-answer">Answer</Label>
            <Input
              id="edit-answer"
              value={editForm.answer}
              onChange={(e) => setEditForm({ ...editForm, answer: e.target.value })}
            />
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <Label htmlFor="edit-difficulty">Difficulty</Label>
              <Select 
                value={editForm.difficulty} 
                onValueChange={(value) => setEditForm({ ...editForm, difficulty: value })}
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
              <Label htmlFor="edit-category">Category</Label>
              <Select 
                value={editForm.category} 
                onValueChange={(value) => setEditForm({ ...editForm, category: value })}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="bible">Bible</SelectItem>
                  <SelectItem value="animals">Animals</SelectItem>
                  <SelectItem value="us_history">US History</SelectItem>
                  <SelectItem value="world_history">World History</SelectItem>
                  <SelectItem value="geography">Geography</SelectItem>
                </SelectContent>
              </Select>
            </div>
            
            <div>
              <Label htmlFor="edit-reference">Reference</Label>
              <Input
                id="edit-reference"
                value={editForm.reference}
                onChange={(e) => setEditForm({ ...editForm, reference: e.target.value })}
                placeholder="Bible verse, source, etc."
              />
            </div>
          </div>
          
          <div className="flex gap-2 justify-end pt-4">
            <Button onClick={handleCancel} variant="outline" disabled={saving}>
              <X className="w-4 h-4 mr-2" />
              Cancel
            </Button>
            <Button onClick={handleSave} disabled={saving}>
              <Save className="w-4 h-4 mr-2" />
              {saving ? 'Saving...' : 'Save Changes'}
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
}