import mongoose from "mongoose";

export const connectDB = async () => {
  const db = process.env.MONGO_CONNECTION;
  if (!db) {
    throw new Error("MONGO_CONNECTION is not set");
  }
  await mongoose.connect(db);
  console.log("Database connection successful");
};
