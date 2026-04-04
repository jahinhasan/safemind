import { useState } from "react";
import { useNavigate } from "react-router";
import { X, Lock } from "lucide-react";
import { motion } from "motion/react";

const CATEGORIES = [
  "Anxiety",
  "Depression",
  "Stress",
  "Relationships",
  "Work",
  "Family",
  "General",
  "Other",
];

export function CreatePost() {
  const navigate = useNavigate();
  const [content, setContent] = useState("");
  const [category, setCategory] = useState("General");
  const [isAnonymous, setIsAnonymous] = useState(true);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    navigate("/");
  };

  return (
    <div className="min-h-screen py-8">
      <div className="max-w-3xl mx-auto px-4 sm:px-6">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="bg-card rounded-3xl p-6 sm:p-10 border border-border shadow-xl"
        >
          {/* Header */}
          <div className="flex items-center justify-between mb-8">
            <h2 className="text-3xl">Share Your Thoughts</h2>
            <button
              onClick={() => navigate(-1)}
              className="size-10 rounded-full hover:bg-muted flex items-center justify-center transition-colors"
            >
              <X className="size-5" />
            </button>
          </div>

          <form onSubmit={handleSubmit} className="space-y-6">
            {/* Anonymous Toggle */}
            <div className="flex items-center justify-between p-4 bg-support-light rounded-2xl border border-support/20">
              <div className="flex items-center gap-3">
                <Lock className="size-5 text-support" />
                <div>
                  <p className="font-medium">Post Anonymously</p>
                  <p className="text-sm text-muted-foreground">Your identity will be protected</p>
                </div>
              </div>
              <label className="relative inline-block w-14 h-8">
                <input
                  type="checkbox"
                  checked={isAnonymous}
                  onChange={(e) => setIsAnonymous(e.target.checked)}
                  className="sr-only peer"
                />
                <div className="w-full h-full bg-muted rounded-full peer-checked:bg-support transition-all cursor-pointer" />
                <div className="absolute top-1 left-1 size-6 bg-white rounded-full transition-all peer-checked:translate-x-6 shadow-md" />
              </label>
            </div>

            {/* Category Selection */}
            <div>
              <label className="block mb-3">Category</label>
              <div className="flex flex-wrap gap-2">
                {CATEGORIES.map((cat) => (
                  <button
                    key={cat}
                    type="button"
                    onClick={() => setCategory(cat)}
                    className={`px-4 py-2 rounded-full transition-all ${
                      category === cat
                        ? "bg-primary text-primary-foreground shadow-md"
                        : "bg-muted hover:bg-accent"
                    }`}
                  >
                    {cat}
                  </button>
                ))}
              </div>
            </div>

            {/* Content */}
            <div>
              <label className="block mb-3">What's on your mind?</label>
              <textarea
                value={content}
                onChange={(e) => setContent(e.target.value)}
                placeholder="Share your thoughts, feelings, or ask for support..."
                rows={8}
                className="w-full px-6 py-4 bg-input-background rounded-2xl border border-border focus:outline-none focus:ring-2 focus:ring-ring transition-all resize-none"
              />
              <p className="mt-2 text-sm text-muted-foreground text-right">
                {content.length} characters
              </p>
            </div>

            {/* Actions */}
            <div className="flex gap-3">
              <motion.button
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                type="submit"
                className="flex-1 py-3.5 bg-gradient-to-r from-support to-primary text-white rounded-2xl shadow-lg hover:shadow-xl transition-all"
              >
                Post
              </motion.button>
              <button
                type="button"
                onClick={() => navigate(-1)}
                className="px-6 py-3.5 bg-muted hover:bg-accent rounded-2xl transition-all"
              >
                Cancel
              </button>
            </div>
          </form>
        </motion.div>
      </div>
    </div>
  );
}
