import { useState } from "react";
import { Shield, AlertTriangle, Users, MessageCircle, TrendingUp, Trash2, Eye, Ban } from "lucide-react";
import { motion } from "motion/react";

const MOCK_REPORTS = [
  {
    id: 1,
    type: "post",
    content: "Inappropriate content reported by 3 users",
    reporter: "Anonymous User",
    timestamp: "10 minutes ago",
    severity: "high",
  },
  {
    id: 2,
    type: "comment",
    content: "Spam in multiple comments",
    reporter: "User123",
    timestamp: "1 hour ago",
    severity: "medium",
  },
  {
    id: 3,
    type: "user",
    content: "Suspicious behavior pattern detected",
    reporter: "System",
    timestamp: "2 hours ago",
    severity: "low",
  },
];

const MOCK_STATS = [
  { label: "Total Users", value: "1,234", icon: Users, color: "support" },
  { label: "Active Posts", value: "456", icon: MessageCircle, color: "primary" },
  { label: "Reports", value: "12", icon: AlertTriangle, color: "destructive" },
  { label: "Growth", value: "+23%", icon: TrendingUp, color: "advisor" },
];

export function Admin() {
  const [activeTab, setActiveTab] = useState<"overview" | "reports" | "users">("overview");

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 py-8">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="mb-8"
      >
        <div className="flex items-center gap-3 mb-2">
          <Shield className="size-8 text-primary" />
          <h1 className="text-4xl">Admin Dashboard</h1>
        </div>
        <p className="text-muted-foreground">Monitor and manage platform activity</p>
      </motion.div>

      {/* Tabs */}
      <div className="flex gap-2 mb-8 overflow-x-auto pb-2">
        <button
          onClick={() => setActiveTab("overview")}
          className={`px-6 py-3 rounded-2xl whitespace-nowrap transition-all ${
            activeTab === "overview" ? "bg-primary text-primary-foreground shadow-lg" : "bg-muted hover:bg-accent"
          }`}
        >
          Overview
        </button>
        <button
          onClick={() => setActiveTab("reports")}
          className={`px-6 py-3 rounded-2xl whitespace-nowrap transition-all flex items-center gap-2 ${
            activeTab === "reports" ? "bg-primary text-primary-foreground shadow-lg" : "bg-muted hover:bg-accent"
          }`}
        >
          <AlertTriangle className="size-4" />
          Reports
          <span className="size-5 rounded-full bg-destructive text-white text-xs flex items-center justify-center">
            {MOCK_REPORTS.length}
          </span>
        </button>
        <button
          onClick={() => setActiveTab("users")}
          className={`px-6 py-3 rounded-2xl whitespace-nowrap transition-all ${
            activeTab === "users" ? "bg-primary text-primary-foreground shadow-lg" : "bg-muted hover:bg-accent"
          }`}
        >
          Users
        </button>
      </div>

      {/* Overview Tab */}
      {activeTab === "overview" && (
        <div className="space-y-6">
          {/* Stats Grid */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {MOCK_STATS.map((stat, index) => (
              <motion.div
                key={stat.label}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.1 }}
                className="bg-card rounded-3xl p-6 border border-border shadow-lg"
              >
                <div className="flex items-center justify-between mb-4">
                  <stat.icon className="size-8" style={{ color: `var(--${stat.color})` }} />
                </div>
                <p className="text-3xl mb-1">{stat.value}</p>
                <p className="text-sm text-muted-foreground">{stat.label}</p>
              </motion.div>
            ))}
          </div>

          {/* Recent Activity */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4 }}
            className="bg-card rounded-3xl p-8 border border-border shadow-xl"
          >
            <h3 className="text-2xl mb-6">Recent Activity</h3>
            <div className="space-y-4">
              {[
                { action: "New user registration", user: "user_456", time: "5 minutes ago" },
                { action: "Post reported", user: "Anonymous User", time: "10 minutes ago" },
                { action: "Comment removed", user: "Admin", time: "1 hour ago" },
              ].map((activity, index) => (
                <div
                  key={index}
                  className="flex items-center justify-between p-4 bg-muted rounded-2xl"
                >
                  <div>
                    <p className="font-medium">{activity.action}</p>
                    <p className="text-sm text-muted-foreground">{activity.user}</p>
                  </div>
                  <p className="text-sm text-muted-foreground">{activity.time}</p>
                </div>
              ))}
            </div>
          </motion.div>
        </div>
      )}

      {/* Reports Tab */}
      {activeTab === "reports" && (
        <div className="space-y-4">
          {MOCK_REPORTS.map((report, index) => (
            <motion.div
              key={report.id}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: index * 0.1 }}
              className="bg-card rounded-3xl p-6 border border-border shadow-lg"
            >
              <div className="flex items-start justify-between mb-4">
                <div className="flex items-start gap-4">
                  <div
                    className={`size-12 rounded-full flex items-center justify-center ${
                      report.severity === "high"
                        ? "bg-destructive/20"
                        : report.severity === "medium"
                        ? "bg-accent"
                        : "bg-muted"
                    }`}
                  >
                    <AlertTriangle
                      className={`size-6 ${
                        report.severity === "high" ? "text-destructive" : "text-muted-foreground"
                      }`}
                    />
                  </div>
                  <div>
                    <p className="font-medium mb-1">{report.content}</p>
                    <p className="text-sm text-muted-foreground">
                      Reported by {report.reporter} • {report.timestamp}
                    </p>
                  </div>
                </div>
                <span
                  className={`px-3 py-1 rounded-full text-sm ${
                    report.severity === "high"
                      ? "bg-destructive/20 text-destructive"
                      : report.severity === "medium"
                      ? "bg-accent text-accent-foreground"
                      : "bg-muted text-muted-foreground"
                  }`}
                >
                  {report.severity}
                </span>
              </div>

              <div className="flex gap-3">
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  className="px-4 py-2 bg-primary text-primary-foreground rounded-xl flex items-center gap-2 hover:shadow-lg transition-all"
                >
                  <Eye className="size-4" />
                  Review
                </motion.button>
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  className="px-4 py-2 bg-destructive/10 text-destructive rounded-xl flex items-center gap-2 hover:bg-destructive/20 transition-all"
                >
                  <Trash2 className="size-4" />
                  Remove
                </motion.button>
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  className="px-4 py-2 bg-muted hover:bg-accent rounded-xl flex items-center gap-2 transition-all"
                >
                  <Ban className="size-4" />
                  Ban User
                </motion.button>
              </div>
            </motion.div>
          ))}
        </div>
      )}

      {/* Users Tab */}
      {activeTab === "users" && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="bg-card rounded-3xl p-8 border border-border shadow-xl"
        >
          <h3 className="text-2xl mb-6">User Management</h3>
          <div className="space-y-3">
            {[
              { name: "Anonymous User", posts: 12, joined: "March 2026", status: "active" },
              { name: "Sarah M.", posts: 24, joined: "February 2026", status: "active" },
              { name: "John D.", posts: 8, joined: "April 2026", status: "active" },
            ].map((user, index) => (
              <div
                key={index}
                className="flex items-center justify-between p-4 bg-muted rounded-2xl"
              >
                <div className="flex items-center gap-4">
                  <div className="size-12 rounded-full bg-gradient-to-br from-accent to-primary flex items-center justify-center text-primary-foreground">
                    {user.name[0]}
                  </div>
                  <div>
                    <p className="font-medium">{user.name}</p>
                    <p className="text-sm text-muted-foreground">
                      {user.posts} posts • Joined {user.joined}
                    </p>
                  </div>
                </div>
                <div className="flex items-center gap-3">
                  <span className="px-3 py-1 bg-support-light text-support rounded-full text-sm">
                    {user.status}
                  </span>
                  <button className="px-4 py-2 bg-primary text-primary-foreground rounded-xl hover:shadow-lg transition-all">
                    View
                  </button>
                </div>
              </div>
            ))}
          </div>
        </motion.div>
      )}
    </div>
  );
}
