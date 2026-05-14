import { Outlet, Link, useLocation } from "react-router";
import { Heart, Plus, MessageCircle, User, Shield, Bell } from "lucide-react";
import { motion } from "motion/react";

export function Root() {
  const location = useLocation();
  const userRole = "user"; // Mock - would come from auth context

  return (
    <div className="min-h-screen flex flex-col">
      {/* Header */}
      <header className="sticky top-0 z-50 bg-background/80 backdrop-blur-lg border-b border-border">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 h-16 flex items-center justify-between">
          <Link to="/" className="flex items-center gap-2 group">
            <div className="size-10 rounded-full bg-gradient-to-br from-support to-primary flex items-center justify-center">
              <Heart className="size-5 text-white" />
            </div>
            <h1 className="text-2xl tracking-tight text-foreground group-hover:text-primary transition-colors">
              SafeSpace
            </h1>
          </Link>

          <nav className="flex items-center gap-1">
            <Link
              to="/"
              className={`px-4 py-2 rounded-full transition-all ${
                location.pathname === "/" ? "bg-primary text-primary-foreground" : "hover:bg-muted"
              }`}
            >
              Feed
            </Link>
            <Link
              to="/profile"
              className={`px-4 py-2 rounded-full transition-all ${
                location.pathname === "/profile" ? "bg-primary text-primary-foreground" : "hover:bg-muted"
              }`}
            >
              Profile
            </Link>
            <Link
              to="/chat"
              className={`px-4 py-2 rounded-full transition-all ${
                location.pathname === "/chat" ? "bg-primary text-primary-foreground" : "hover:bg-muted"
              }`}
            >
              <MessageCircle className="size-5" />
            </Link>
            {userRole === "admin" && (
              <Link
                to="/admin"
                className={`px-4 py-2 rounded-full transition-all ${
                  location.pathname === "/admin" ? "bg-primary text-primary-foreground" : "hover:bg-muted"
                }`}
              >
                <Shield className="size-5" />
              </Link>
            )}
            <button className="ml-2 p-2 hover:bg-muted rounded-full transition-all relative">
              <Bell className="size-5" />
              <span className="absolute top-1.5 right-1.5 size-2 bg-destructive rounded-full" />
            </button>
          </nav>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-1">
        <Outlet />
      </main>

      {/* Floating Action Button */}
      <Link to="/create">
        <motion.button
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
          className="fixed bottom-8 right-8 size-16 rounded-full bg-gradient-to-br from-support to-primary text-white shadow-xl flex items-center justify-center z-40"
        >
          <Plus className="size-6" />
        </motion.button>
      </Link>
    </div>
  );
}
