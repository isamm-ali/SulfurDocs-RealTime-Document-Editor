import jwt from "jsonwebtoken";
import mongoose from "mongoose";
import { Document } from "../models/document.js";

const MAX_DELTA_SIZE = 1024 * 1024;

const isValidDelta = (delta) => {
  if (!Array.isArray(delta)) {
    return false;
  }
  try {
    return JSON.stringify(delta).length <= MAX_DELTA_SIZE;
  } catch {
    return false;
  }
};

const authenticateSocket = (socket, next) => {
  const token = socket.handshake.auth?.token;
  if (!token) {
    return next(new Error("Authentication required"));
  }
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    if (!decoded?.userId) {
      return next(new Error("Invalid token"));
    }
    socket.data.userId = decoded.userId;
    next();
  } catch {
    next(new Error("Invalid or expired token"));
  }
};

export const socketServer = (io) => {
  io.use(authenticateSocket);

  io.on("connection", (socket) => {
    console.log("Authenticated user connected:", socket.id, socket.data.userId);
    socket.on("join", async (documentId) => {
      if (!mongoose.isValidObjectId(documentId)) {
        socket.emit("joinError", {
          message: "Invalid document ID",
        });
        return;
      }
      try {
        const document = await Document.findOne({
          _id: documentId,
          uid: socket.data.userId,
        }).select("_id");
        if (!document) {
          socket.emit("joinError", {
            message: "Document not found",
          });
          return;
        }
        socket.join(documentId);
        console.log(`${socket.id} joined room ${documentId}`);
      } catch (error) {
        console.error("Join error:", error);
        socket.emit("joinError", {
          message: "Unable to join document",
        });
      }
    });

    socket.on("typing", (data) => {
      const room = data?.room;
      const delta = data?.delta;
      if (!room || !socket.rooms.has(room)) {
        return;
      }
      if (!isValidDelta(delta)) {
        return;
      }
      socket.broadcast.to(room).emit("changes", {
        delta,
        room,
      });
    });

    socket.on("save", async (data) => {
      const documentId = data?.documentId;
      const delta = data?.delta;

      if (!mongoose.isValidObjectId(documentId)) {
        return;
      }
      if (!socket.rooms.has(documentId)) {
        return;
      }
      if (!isValidDelta(delta)) {
        return;
      }
      try {
        const document = await Document.findOneAndUpdate(
          {
            _id: documentId,
            uid: socket.data.userId,
          },
          {
            $set: {
              content: delta,
            },
          },
          {
            new: true,
            runValidators: true,
          },
        );
        if (!document) {
          console.log("Unauthorized or missing document:", documentId);
          return;
        }
        console.log("Document saved:", documentId);
      } catch (error) {
        console.error("Save error:", error);
      }
    });
    socket.on("disconnect", (reason) => {
      console.log(`User disconnected: ${socket.id} - ${reason}`);
    });
  });
};
