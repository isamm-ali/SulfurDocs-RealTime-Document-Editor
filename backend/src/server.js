import "dotenv/config";
import http from "http";
import { Server } from "socket.io";
import { app } from "./app.js";
import { connectDB } from "./config/database.js";
import { socketServer } from "./socket/socketServer.js";

const PORT = process.env.PORT || 5000;
const FRONTEND_URL = process.env.FRONTEND_URL;
const httpServer = http.createServer(app);

const isAllowedOrigin = (origin) => {
  if (!origin) {
    return true;
  }
  if (
    origin.startsWith("http://localhost:") ||
    origin.startsWith("http://127.0.0.1:")
  ) {
    return true;
  }
  return origin === FRONTEND_URL;
};

const io = new Server(httpServer, {
  cors: {
    origin: (origin, callback) => {
      if (isAllowedOrigin(origin)) {
        callback(null, true);
      } else {
        callback(new Error("Origin not allowed by CORS"));
      }
    },
    methods: ["GET", "POST"],
  },
  transports: ["polling", "websocket"],
});

socketServer(io);

try {
  await connectDB();
} catch (error) {
  console.error("Database connection failed:", error);
  process.exit(1);
}
httpServer.listen(PORT, "0.0.0.0", () => {
  console.log(`Server is running on port ${PORT}`);
});
