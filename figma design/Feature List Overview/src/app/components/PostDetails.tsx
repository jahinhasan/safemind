import { useState } from "react";
import { useParams, useNavigate } from "react-router";
import { Heart, MessageCircle, Award, CheckCircle, Send, ArrowLeft, MoreVertical } from "lucide-react";
import { motion } from "motion/react";

const MOCK_POST = {
  id: 1,
  author: "Anonymous User",
  isAnonymous: true,
  timestamp: "2 hours ago",
  content: "I've been struggling with anxiety lately and it's affecting my work. Does anyone have tips on managing stress during busy periods?",
  likes: 24,
  category: "Anxiety",
  isLiked: false,
};

const MOCK_COMMENTS = [
  {
    id: 1,
    author: "Dr. Sarah Johnson",
    isAdvisor: true,
    timestamp: "1 hour ago",
    content: "I recommend starting with breathing exercises. Try the 4-7-8 technique: breathe in for 4 seconds, hold for 7, exhale for 8. This activates your parasympathetic nervous system and can help during stressful moments.",
    likes: 18,
    isBestSolution: true,
  },
  {
    id: 2,
    author: "Anonymous User",
    isAdvisor: false,
    timestamp: "1 hour ago",
    content: "I've been there! What helped me was breaking tasks into smaller chunks and taking regular breaks. Also, talking to someone you trust can really help.",
    likes: 12,
    isBestSolution: false,
  },
  {
    id: 3,
    author: "Mark Thompson",
    isAdvisor: true,
    timestamp: "30 minutes ago",
    content: "Consider keeping a journal to identify your anxiety triggers. Understanding patterns can help you develop coping strategies specific to your situation.",
    likes: 9,
    isBestSolution: false,
  },
];

export function PostDetails() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [comment, setComment] = useState("");
  const [isLiked, setIsLiked] = useState(false);
  const [likes, setLikes] = useState(MOCK_POST.likes);

  const handleLike = () => {
    setIsLiked(!isLiked);
    setLikes(isLiked ? likes - 1 : likes + 1);
  };

  const handleCommentSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setComment("");
  };

  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 py-8">
      {/* Back Button */}
      <button
        onClick={() => navigate(-1)}
        className="flex items-center gap-2 mb-6 text-muted-foreground hover:text-foreground transition-colors"
      >
        <ArrowLeft className="size-5" />
        Back to Feed
      </button>

      {/* Post */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="bg-card rounded-3xl p-6 sm:p-8 border border-border shadow-xl mb-6"
      >
        {/* Header */}
        <div className="flex items-start justify-between mb-6">
          <div className="flex items-center gap-3">
            <div className="size-14 rounded-full bg-gradient-to-br from-accent to-primary flex items-center justify-center text-primary-foreground text-xl">
              A
            </div>
            <div>
              <p className="font-medium text-lg">{MOCK_POST.author}</p>
              <p className="text-sm text-muted-foreground">{MOCK_POST.timestamp}</p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <span className="px-3 py-1 bg-support-light text-support rounded-full text-sm">
              {MOCK_POST.category}
            </span>
            <button className="size-10 rounded-full hover:bg-muted flex items-center justify-center transition-colors">
              <MoreVertical className="size-5" />
            </button>
          </div>
        </div>

        {/* Content */}
        <p className="text-lg leading-relaxed mb-6">{MOCK_POST.content}</p>

        {/* Actions */}
        <div className="flex items-center gap-4">
          <motion.button
            whileTap={{ scale: 0.9 }}
            onClick={handleLike}
            className={`flex items-center gap-2 px-4 py-2 rounded-full transition-all ${
              isLiked ? "bg-destructive/10 text-destructive" : "bg-muted hover:bg-accent"
            }`}
          >
            <Heart className={`size-5 ${isLiked ? "fill-current" : ""}`} />
            <span>{likes}</span>
          </motion.button>
          <div className="flex items-center gap-2 px-4 py-2 bg-muted rounded-full">
            <MessageCircle className="size-5" />
            <span>{MOCK_COMMENTS.length}</span>
          </div>
        </div>
      </motion.div>

      {/* Comments Section */}
      <div className="space-y-4">
        <h3 className="text-2xl mb-6">
          Responses ({MOCK_COMMENTS.length})
        </h3>

        {MOCK_COMMENTS.map((comment, index) => (
          <motion.div
            key={comment.id}
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: index * 0.1 }}
            className={`relative bg-card rounded-2xl p-6 border ${
              comment.isBestSolution
                ? "border-support shadow-lg ring-2 ring-support/20"
                : "border-border"
            }`}
          >
            {comment.isBestSolution && (
              <div className="absolute -top-3 left-6 px-3 py-1 bg-support text-white rounded-full text-sm flex items-center gap-1.5">
                <CheckCircle className="size-3.5" />
                Best Solution
              </div>
            )}

            <div className="flex items-start gap-4">
              <div className={`size-12 rounded-full flex items-center justify-center text-white ${
                comment.isAdvisor ? "bg-gradient-to-br from-advisor to-primary" : "bg-gradient-to-br from-accent to-muted-foreground"
              }`}>
                {comment.author[0]}
              </div>

              <div className="flex-1">
                <div className="flex items-center gap-2 mb-2">
                  <p className="font-medium">{comment.author}</p>
                  {comment.isAdvisor && (
                    <span className="px-2 py-0.5 bg-advisor-light text-advisor rounded-full text-xs flex items-center gap-1">
                      <Award className="size-3" />
                      Advisor
                    </span>
                  )}
                  <span className="text-sm text-muted-foreground">· {comment.timestamp}</span>
                </div>
                <p className="text-foreground leading-relaxed mb-3">{comment.content}</p>
                <button className="flex items-center gap-2 text-sm text-muted-foreground hover:text-destructive transition-colors">
                  <Heart className="size-4" />
                  <span>{comment.likes}</span>
                </button>
              </div>
            </div>
          </motion.div>
        ))}
      </div>

      {/* Add Comment */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.4 }}
        className="mt-8 bg-card rounded-2xl p-6 border border-border"
      >
        <form onSubmit={handleCommentSubmit} className="flex gap-3">
          <div className="size-12 rounded-full bg-gradient-to-br from-accent to-primary flex items-center justify-center text-primary-foreground">
            A
          </div>
          <div className="flex-1 flex gap-3">
            <input
              type="text"
              value={comment}
              onChange={(e) => setComment(e.target.value)}
              placeholder="Share your thoughts or advice..."
              className="flex-1 px-6 py-3 bg-input-background rounded-2xl border border-border focus:outline-none focus:ring-2 focus:ring-ring transition-all"
            />
            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              type="submit"
              className="px-6 py-3 bg-primary text-primary-foreground rounded-2xl hover:shadow-lg transition-all flex items-center gap-2"
            >
              <Send className="size-4" />
              Send
            </motion.button>
          </div>
        </form>
      </motion.div>
    </div>
  );
}
