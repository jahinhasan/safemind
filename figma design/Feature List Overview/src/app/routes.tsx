import { createBrowserRouter } from "react-router";
import { Root } from "./components/Root";
import { Login } from "./components/Login";
import { Home } from "./components/Home";
import { CreatePost } from "./components/CreatePost";
import { PostDetails } from "./components/PostDetails";
import { Profile } from "./components/Profile";
import { Chat } from "./components/Chat";
import { Admin } from "./components/Admin";
import { NotFound } from "./components/NotFound";

export const router = createBrowserRouter([
  {
    path: "/login",
    Component: Login,
  },
  {
    path: "/",
    Component: Root,
    children: [
      { index: true, Component: Home },
      { path: "create", Component: CreatePost },
      { path: "post/:id", Component: PostDetails },
      { path: "profile", Component: Profile },
      { path: "chat", Component: Chat },
      { path: "admin", Component: Admin },
      { path: "*", Component: NotFound },
    ],
  },
]);
