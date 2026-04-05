import { useState } from "react";
import { Search, Send, MoreVertical } from "lucide-react";
import { motion } from "motion/react";

const MOCK_CONVERSATIONS = [
  {
    id: 1,
    name: "Sarah M.",
    lastMessage: "Thank you so much for your support!",
    timestamp: "5m ago",
    unread: 2,
    avatar: "S",
  },
  {
    id: 2,
    name: "Anonymous User",
    lastMessage: "I really appreciate you listening",
    timestamp: "2h ago",
    unread: 0,
    avatar: "A",
  },
  {
    id: 3,
    name: "John D.",
    lastMessage: "Hope you're doing better today",
    timestamp: "1d ago",
    unread: 0,
    avatar: "J",
  },
];

const MOCK_MESSAGES = [
  {
    id: 1,
    sender: "other",
    content: "Hi, I saw your post about anxiety. I've been through something similar.",
    timestamp: "10:23 AM",
  },
  {
    id: 2,
    sender: "me",
    content: "Thank you for reaching out! It really means a lot.",
    timestamp: "10:25 AM",
  },
  {
    id: 3,
    sender: "other",
    content: "What helped me was finding a routine and sticking to it. Also therapy was really beneficial.",
    timestamp: "10:27 AM",
  },
  {
    id: 4,
    sender: "me",
    content: "That's really helpful advice. I've been thinking about therapy but wasn't sure where to start.",
    timestamp: "10:30 AM",
  },
  {
    id: 5,
    sender: "other",
    content: "Thank you so much for your support!",
    timestamp: "10:32 AM",
  },
];

export function Chat() {
  const [selectedChat, setSelectedChat] = useState(MOCK_CONVERSATIONS[0]);
  const [message, setMessage] = useState("");
  const [searchQuery, setSearchQuery] = useState("");

  const handleSendMessage = (e: React.FormEvent) => {
    e.preventDefault();
    setMessage("");
  };

  return (
    <div className="h-[calc(100vh-4rem)] flex">
      {/* Conversations List */}
      <div className="w-80 border-r border-border bg-sidebar flex flex-col">
        {/* Search */}
        <div className="p-4 border-b border-border">
          <div className="relative">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 size-5 text-muted-foreground" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search conversations..."
              className="w-full pl-12 pr-4 py-3 bg-background rounded-2xl border border-border focus:outline-none focus:ring-2 focus:ring-ring transition-all"
            />
          </div>
        </div>

        {/* Conversation List */}
        <div className="flex-1 overflow-y-auto">
          {MOCK_CONVERSATIONS.map((conversation) => (
            <motion.button
              key={conversation.id}
              whileHover={{ backgroundColor: "var(--muted)" }}
              onClick={() => setSelectedChat(conversation)}
              className={`w-full p-4 flex items-start gap-3 border-b border-border transition-colors ${
                selectedChat.id === conversation.id ? "bg-muted" : ""
              }`}
            >
              <div className="size-12 rounded-full bg-gradient-to-br from-accent to-primary flex items-center justify-center text-primary-foreground shrink-0">
                {conversation.avatar}
              </div>
              <div className="flex-1 text-left overflow-hidden">
                <div className="flex items-center justify-between mb-1">
                  <p className="font-medium truncate">{conversation.name}</p>
                  <span className="text-xs text-muted-foreground">{conversation.timestamp}</span>
                </div>
                <div className="flex items-center justify-between">
                  <p className="text-sm text-muted-foreground truncate">{conversation.lastMessage}</p>
                  {conversation.unread > 0 && (
                    <span className="ml-2 size-5 rounded-full bg-destructive text-white text-xs flex items-center justify-center shrink-0">
                      {conversation.unread}
                    </span>
                  )}
                </div>
              </div>
            </motion.button>
          ))}
        </div>
      </div>

      {/* Chat Area */}
      <div className="flex-1 flex flex-col">
        {/* Chat Header */}
        <div className="h-16 border-b border-border px-6 flex items-center justify-between bg-card">
          <div className="flex items-center gap-3">
            <div className="size-10 rounded-full bg-gradient-to-br from-accent to-primary flex items-center justify-center text-primary-foreground">
              {selectedChat.avatar}
            </div>
            <p className="font-medium">{selectedChat.name}</p>
          </div>
          <button className="size-10 rounded-full hover:bg-muted flex items-center justify-center transition-colors">
            <MoreVertical className="size-5" />
          </button>
        </div>

        {/* Messages */}
        <div className="flex-1 overflow-y-auto p-6 space-y-4">
          {MOCK_MESSAGES.map((msg, index) => (
            <motion.div
              key={msg.id}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: index * 0.05 }}
              className={`flex ${msg.sender === "me" ? "justify-end" : "justify-start"}`}
            >
              <div
                className={`max-w-md px-5 py-3 rounded-3xl ${
                  msg.sender === "me"
                    ? "bg-gradient-to-r from-support to-primary text-white rounded-br-md"
                    : "bg-muted text-foreground rounded-bl-md"
                }`}
              >
                <p className="leading-relaxed">{msg.content}</p>
                <p
                  className={`text-xs mt-1 ${
                    msg.sender === "me" ? "text-white/70" : "text-muted-foreground"
                  }`}
                >
                  {msg.timestamp}
                </p>
              </div>
            </motion.div>
          ))}
        </div>

        {/* Message Input */}
        <div className="border-t border-border p-4 bg-card">
          <form onSubmit={handleSendMessage} className="flex gap-3">
            <input
              type="text"
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              placeholder="Type a message..."
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
          </form>
        </div>
      </div>
    </div>
  );
}
