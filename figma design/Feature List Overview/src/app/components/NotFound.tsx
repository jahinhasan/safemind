import { Link } from "react-router";
import { Home, AlertCircle } from "lucide-react";
import { motion } from "motion/react";

export function NotFound() {
  return (
    <div className="min-h-screen flex items-center justify-center p-4">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="text-center"
      >
        <div className="size-32 mx-auto mb-8 rounded-full bg-muted flex items-center justify-center">
          <AlertCircle className="size-16 text-muted-foreground" />
        </div>
        <h1 className="text-6xl mb-4">404</h1>
        <h2 className="text-2xl mb-4">Page Not Found</h2>
        <p className="text-muted-foreground mb-8 max-w-md">
          The page you're looking for doesn't exist or has been moved.
        </p>
        <Link
          to="/"
          className="inline-flex items-center gap-2 px-6 py-3 bg-primary text-primary-foreground rounded-2xl hover:shadow-lg transition-all"
        >
          <Home className="size-5" />
          Back to Home
        </Link>
      </motion.div>
    </div>
  );
}
