import { useState } from "react";
import { User, Calendar, TrendingUp, Heart, MessageCircle, Settings } from "lucide-react";
import { motion } from "motion/react";

const MOOD_DATA = [
  { date: "Mon", mood: 4 },
  { date: "Tue", mood: 3 },
  { date: "Wed", mood: 5 },
  { date: "Thu", mood: 3 },
  { date: "Fri", mood: 4 },
  { date: "Sat", mood: 5 },
  { date: "Sun", mood: 4 },
];

const MOOD_LABELS = ["Awful", "Bad", "Okay", "Good", "Great"];
const MOOD_COLORS = [
  "var(--mood-awful)",
  "var(--mood-bad)",
  "var(--mood-okay)",
  "var(--mood-good)",
  "var(--mood-great)",
];

export function Profile() {
  const [currentMood, setCurrentMood] = useState(3);

  return (
    <div className="max-w-5xl mx-auto px-4 sm:px-6 py-8">
      {/* Profile Header */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="bg-card rounded-3xl p-8 border border-border shadow-xl mb-8"
      >
        <div className="flex items-start justify-between mb-6">
          <div className="flex items-center gap-6">
            <div className="size-24 rounded-full bg-gradient-to-br from-support to-primary flex items-center justify-center text-white text-3xl">
              A
            </div>
            <div>
              <h2 className="text-3xl mb-2">Anonymous User</h2>
              <p className="text-muted-foreground">Member since March 2026</p>
            </div>
          </div>
          <button className="size-12 rounded-full hover:bg-muted flex items-center justify-center transition-colors">
            <Settings className="size-5" />
          </button>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-3 gap-6">
          <div className="text-center p-4 bg-support-light rounded-2xl">
            <p className="text-3xl mb-1">12</p>
            <p className="text-sm text-muted-foreground">Posts</p>
          </div>
          <div className="text-center p-4 bg-advisor-light rounded-2xl">
            <p className="text-3xl mb-1">48</p>
            <p className="text-sm text-muted-foreground">Responses</p>
          </div>
          <div className="text-center p-4 bg-muted rounded-2xl">
            <p className="text-3xl mb-1">156</p>
            <p className="text-sm text-muted-foreground">Support Given</p>
          </div>
        </div>
      </motion.div>

      {/* Mood Tracker */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.1 }}
        className="bg-card rounded-3xl p-8 border border-border shadow-xl mb-8"
      >
        <div className="flex items-center gap-3 mb-6">
          <TrendingUp className="size-6 text-primary" />
          <h3 className="text-2xl">Mood Tracker</h3>
        </div>

        {/* Current Mood */}
        <div className="mb-8">
          <p className="mb-4">How are you feeling today?</p>
          <div className="flex gap-3">
            {[1, 2, 3, 4, 5].map((mood) => (
              <motion.button
                key={mood}
                whileHover={{ scale: 1.1 }}
                whileTap={{ scale: 0.9 }}
                onClick={() => setCurrentMood(mood)}
                className={`flex-1 py-4 rounded-2xl transition-all ${
                  currentMood === mood ? "shadow-lg ring-2 ring-offset-2" : "opacity-60 hover:opacity-100"
                }`}
                style={{
                  backgroundColor: MOOD_COLORS[mood - 1],
                  color: "white",
                  ringColor: MOOD_COLORS[mood - 1],
                }}
              >
                {MOOD_LABELS[mood - 1]}
              </motion.button>
            ))}
          </div>
        </div>

        {/* Mood Chart */}
        <div>
          <p className="mb-4">Your week at a glance</p>
          <div className="flex items-end justify-between gap-3 h-48">
            {MOOD_DATA.map((day, index) => (
              <motion.div
                key={day.date}
                initial={{ height: 0 }}
                animate={{ height: `${(day.mood / 5) * 100}%` }}
                transition={{ delay: 0.2 + index * 0.1, type: "spring" }}
                className="flex-1 rounded-t-xl relative group"
                style={{ backgroundColor: MOOD_COLORS[day.mood - 1] }}
              >
                <div className="absolute -top-8 left-1/2 -translate-x-1/2 opacity-0 group-hover:opacity-100 transition-opacity">
                  <div className="px-2 py-1 bg-foreground text-background rounded text-xs whitespace-nowrap">
                    {MOOD_LABELS[day.mood - 1]}
                  </div>
                </div>
                <p className="absolute -bottom-6 left-1/2 -translate-x-1/2 text-sm text-muted-foreground">
                  {day.date}
                </p>
              </motion.div>
            ))}
          </div>
        </div>
      </motion.div>

      {/* Activity */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2 }}
        className="bg-card rounded-3xl p-8 border border-border shadow-xl"
      >
        <div className="flex items-center gap-3 mb-6">
          <Calendar className="size-6 text-primary" />
          <h3 className="text-2xl">Recent Activity</h3>
        </div>

        <div className="space-y-4">
          {[
            { type: "post", content: "Posted in Anxiety", time: "2 hours ago" },
            { type: "comment", content: "Commented on 'Feeling overwhelmed'", time: "5 hours ago" },
            { type: "like", content: "Supported 3 posts", time: "1 day ago" },
          ].map((activity, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.3 + index * 0.1 }}
              className="flex items-center gap-4 p-4 bg-muted rounded-2xl"
            >
              <div className="size-10 rounded-full bg-primary flex items-center justify-center text-primary-foreground">
                {activity.type === "post" && <MessageCircle className="size-5" />}
                {activity.type === "comment" && <MessageCircle className="size-5" />}
                {activity.type === "like" && <Heart className="size-5" />}
              </div>
              <div className="flex-1">
                <p className="font-medium">{activity.content}</p>
                <p className="text-sm text-muted-foreground">{activity.time}</p>
              </div>
            </motion.div>
          ))}
        </div>
      </motion.div>
    </div>
  );
}
