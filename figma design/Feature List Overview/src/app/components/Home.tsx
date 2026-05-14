import { useState } from "react";
import { Link } from "react-router";
import {
  Heart,
  MessageCircle,
  Award,
  TrendingUp,
  Clock,
  Filter,
} from "lucide-react";
import { motion } from "motion/react";

const MOCK_POSTS = [
  {
    id: 1,
    author: "Anonymous User",
    isAnonymous: true,
    timestamp: "2 hours ago",
    content:
      "I've been struggling with anxiety lately and it's affecting my work. Does anyone have tips on managing stress during busy periods?",
    likes: 24,
    comments: 12,
    isSolved: false,
    category: "Anxiety",
  },
  {
    id: 2,
    author: "Anonymous User",
    isAnonymous: true,
    timestamp: "5 hours ago",
    content:
      "Just wanted to share that I finally talked to my family about my feelings. It was scary but they were so supportive. To anyone hesitating - you're not alone!",
    likes: 89,
    comments: 23,
    isSolved: true,
    category: "Support",
    hasAdvisorResponse: true,
  },
  {
    id: 3,
    author: "Anonymous User",
    isAnonymous: true,
    timestamp: "1 day ago",
    content:
      "Feeling overwhelmed with everything going on. Sometimes I just need someone to listen without judgment.",
    likes: 45,
    comments: 18,
    isSolved: false,
    category: "General",
  },
];

export function Home() {
  const [filter, setFilter] = useState<
    "all" | "unsolved" | "trending"
  >("all");

  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 py-8">
      {/* Filter Tabs */}
      <div className="mb-8 flex items-center gap-3 overflow-x-auto pb-2">
        <button
          onClick={() => setFilter("all")}
          className={`px-6 py-2.5 rounded-full whitespace-nowrap transition-all ${
            filter === "all"
              ? "bg-primary text-primary-foreground shadow-md"
              : "bg-muted hover:bg-accent"
          }`}
        >
          All Posts
        </button>
        <button
          onClick={() => setFilter("unsolved")}
          className={`px-6 py-2.5 rounded-full whitespace-nowrap transition-all flex items-center gap-2 ${
            filter === "unsolved"
              ? "bg-primary text-primary-foreground shadow-md"
              : "bg-muted hover:bg-accent"
          }`}
        >
          <MessageCircle className="size-4" />
          Needs Support
        </button>
        <button
          onClick={() => setFilter("trending")}
          className={`px-6 py-2.5 rounded-full whitespace-nowrap transition-all flex items-center gap-2 ${
            filter === "trending"
              ? "bg-primary text-primary-foreground shadow-md"
              : "bg-muted hover:bg-accent"
          }`}
        >
          <TrendingUp className="size-4" />
          Trending
        </button>
      </div>

      {/* Posts Feed */}
      <div className="space-y-6">
        {MOCK_POSTS.map((post, index) => (
          <motion.div
            key={post.id}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.1 }}
          >
            <Link to={`/post/${post.id}`}>
              <div className="bg-card rounded-3xl p-6 sm:p-8 border border-border hover:shadow-xl hover:border-primary/30 transition-all group">
                {/* Header */}
                <div className="flex items-start justify-between mb-4">
                  <div className="flex items-center gap-3">
                    <div className="size-12 rounded-full bg-gradient-to-br from-accent to-primary flex items-center justify-center text-primary-foreground">
                      A
                    </div>
                    <div>
                      <p className="font-medium">
                        {post.author}
                      </p>
                      <div className="flex items-center gap-2 text-sm text-muted-foreground">
                        <Clock className="size-3.5" />
                        <span>{post.timestamp}</span>
                      </div>
                    </div>
                  </div>
                  <span className="px-3 py-1 bg-support-light text-support rounded-full text-sm">
                    {post.category}
                  </span>
                </div>

                {/* Content */}
                <p className="text-foreground mb-6 leading-relaxed">
                  {post.content}
                </p>

                {/* Footer */}
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-6">
                    <button className="flex items-center gap-2 text-muted-foreground hover:text-destructive transition-colors">
                      <Heart className="size-5" />
                      <span>{post.likes}</span>
                    </button>
                    <button className="flex items-center gap-2 text-muted-foreground hover:text-primary transition-colors">
                      <MessageCircle className="size-5" />
                      <span>{post.comments}</span>
                    </button>
                  </div>

                  <div className="flex items-center gap-2">
                    {post.hasAdvisorResponse && (
                      <span className="px-3 py-1 bg-advisor-light text-advisor rounded-full text-sm flex items-center gap-1.5">
                        <Award className="size-3.5" />
                        Advisor
                      </span>
                    )}
                    {post.isSolved && (
                      <span className="px-3 py-1 bg-support-light text-support rounded-full text-sm">
                        Solved
                      </span>
                    )}
                  </div>
                </div>
              </div>
            </Link>
          </motion.div>
        ))}
      </div>

      {/* Empty State */}
      {MOCK_POSTS.length === 0 && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="text-center py-20"
        >
          <div className="size-24 mx-auto mb-6 rounded-full bg-muted flex items-center justify-center">
            <Heart className="size-12 text-muted-foreground" />
          </div>
          <h3 className="text-xl mb-2">No posts yet</h3>
          <p className="text-muted-foreground mb-6">
            Be the first to share your story
          </p>
          <Link
            to="/create"
            className="inline-block px-6 py-3 bg-primary text-primary-foreground rounded-2xl hover:shadow-lg transition-all"
          >
            Create Post
          </Link>
        </motion.div>
      )}
    </div>
  );
}