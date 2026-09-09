import express from "express";
import cors from "cors";

import { router as authRouter } from "./routes/authRoutes.js";
import { router as documentRouter } from "./routes/documentRoutes.js";

export const app = express();

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
  return origin === process.env.FRONTEND_URL;
};

app.use(
  cors({
    origin: (origin, callback) => {
      if (isAllowedOrigin(origin)) {
        callback(null, true);
      } else {
        callback(new Error("Origin not allowed by CORS"));
      }
    },
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
  }),
);

app.use(express.json({ limit: "1mb" }));

app.get("/health", (_req, res) => {
  res.status(200).json({
    status: "ok",
  });
});

app.use("/", authRouter);
app.use("/", documentRouter);
