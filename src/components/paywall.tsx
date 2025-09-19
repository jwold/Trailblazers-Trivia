import { Dialog, DialogContent } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Check, X, Sparkles } from "lucide-react";
import { useState } from "react";

interface PaywallProps {
  isOpen: boolean;
  onClose: () => void;
  onUnlock: () => void;
}

export default function Paywall({ isOpen, onClose, onUnlock }: PaywallProps) {
  const [selectedPlan, setSelectedPlan] = useState<'monthly' | 'annual'>('annual');

  const handleUnlock = () => {
    // Simulate purchase - in real app would handle payment
    localStorage.setItem('premium_unlocked', 'true');
    onUnlock();
    onClose();
  };

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-md p-0 overflow-hidden border-0">
        {/* Close button */}
        <button
          onClick={onClose}
          className="absolute right-4 top-4 z-10 w-8 h-8 rounded-full bg-gray-100/80 backdrop-blur-sm hover:bg-gray-200/80 flex items-center justify-center transition-colors"
        >
          <X size={20} className="text-gray-600" />
        </button>

        {/* Header section */}
        <div className="pt-12 pb-6 px-6 text-center bg-gradient-to-b from-gray-50 to-white">
          {/* Icon */}
          <div className="w-20 h-20 bg-gradient-to-br from-yellow-400 to-yellow-500 rounded-3xl flex items-center justify-center mx-auto mb-6 shadow-lg">
            <span className="text-4xl">👑</span>
          </div>
          <h2 className="text-3xl font-bold mb-3 text-gray-900">Trailblazers Pro</h2>
          <p className="text-gray-600 text-lg">Unlock all categories and features</p>
        </div>

        {/* Content section */}
        <div className="px-6 pb-6 space-y-6 bg-white">
          {/* Benefits list */}
          <div className="space-y-3">
            {[
              { emoji: "🎯", text: "All 5 trivia categories" },
              { emoji: "❓", text: "Thousands of questions" },
              { emoji: "✨", text: "New content weekly" },
              { emoji: "🏆", text: "Premium game modes" }
            ].map((benefit, index) => (
              <div key={index} className="flex items-center gap-3">
                <span className="text-xl">{benefit.emoji}</span>
                <span className="text-gray-700">{benefit.text}</span>
              </div>
            ))}
          </div>

          {/* Pricing plans */}
          <div className="space-y-3">
            {/* Annual Plan */}
            <button
              onClick={() => setSelectedPlan('annual')}
              className={`w-full p-4 rounded-2xl transition-all relative ${
                selectedPlan === 'annual'
                  ? 'bg-blue-500 text-white shadow-lg transform scale-[1.02]'
                  : 'bg-gray-50 hover:bg-gray-100'
              }`}
            >
              {/* Most Popular badge */}
              {selectedPlan === 'annual' && (
                <div className="absolute -top-2 right-4">
                  <div className="bg-green-500 text-white text-xs px-2 py-0.5 rounded-full font-medium">
                    SAVE 33%
                  </div>
                </div>
              )}
              <div className="flex justify-between items-center">
                <div className="text-left">
                  <div className={`font-semibold ${selectedPlan === 'annual' ? 'text-white' : 'text-gray-900'}`}>
                    Yearly
                  </div>
                  <div className={`text-sm ${selectedPlan === 'annual' ? 'text-white/80' : 'text-gray-500'}`}>
                    Best value
                  </div>
                </div>
                <div className="text-right">
                  <div className={`text-2xl font-bold ${selectedPlan === 'annual' ? 'text-white' : 'text-gray-900'}`}>
                    $39.99
                  </div>
                  <div className={`text-xs ${selectedPlan === 'annual' ? 'text-white/80' : 'text-gray-500'}`}>
                    $3.33/month
                  </div>
                </div>
              </div>
            </button>

            {/* Monthly Plan */}
            <button
              onClick={() => setSelectedPlan('monthly')}
              className={`w-full p-4 rounded-2xl transition-all ${
                selectedPlan === 'monthly'
                  ? 'bg-blue-500 text-white shadow-lg transform scale-[1.02]'
                  : 'bg-gray-50 hover:bg-gray-100'
              }`}
            >
              <div className="flex justify-between items-center">
                <div className="text-left">
                  <div className={`font-semibold ${selectedPlan === 'monthly' ? 'text-white' : 'text-gray-900'}`}>
                    Monthly
                  </div>
                  <div className={`text-sm ${selectedPlan === 'monthly' ? 'text-white/80' : 'text-gray-500'}`}>
                    Flexible
                  </div>
                </div>
                <div className="text-right">
                  <div className={`text-2xl font-bold ${selectedPlan === 'monthly' ? 'text-white' : 'text-gray-900'}`}>
                    $4.99
                  </div>
                  <div className={`text-xs ${selectedPlan === 'monthly' ? 'text-white/80' : 'text-gray-500'}`}>
                    per month
                  </div>
                </div>
              </div>
            </button>
          </div>

          {/* CTA Button */}
          <Button
            onClick={handleUnlock}
            className="w-full bg-blue-500 hover:bg-blue-600 text-white py-4 text-base font-semibold rounded-2xl shadow-sm"
          >
            Subscribe to Premium
          </Button>

          {/* Terms and links */}
          <div className="text-center space-y-3">
            <p className="text-xs text-gray-400">
              Cancel anytime in Settings
            </p>
            <div className="flex justify-center gap-6 text-xs">
              <button className="text-gray-500 hover:text-gray-700">
                Restore Purchase
              </button>
              <button className="text-gray-500 hover:text-gray-700">
                Terms
              </button>
              <button className="text-gray-500 hover:text-gray-700">
                Privacy
              </button>
            </div>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
}