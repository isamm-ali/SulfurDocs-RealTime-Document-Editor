# Real-Time Document Editor

A Google Docs-style document editor built from scratch with Flutter, Node.js, MongoDB and Socket.IO.

[<video src="https://raw.githubusercontent.com/isamm-ali/SulfurDocs-RealTime-Document-Editor/main/images/clipsulfurdocs.mp4" controls width="800"></video>](https://github.com/user-attachments/assets/22b04eb9-9b0e-4e04-814d-14cee1c63d68)

![Document Editor](https://raw.githubusercontent.com/isamm-ali/Realtime-Document-Editor/main/images/image1.png)


The project started as a way to learn how a collaborative editor actually works beyond the UI. It now has authentication, document storage, a rich text editor, real-time document updates and automatic saving.

## What it does
* Create and edit documents
* Rename documents
* Store documents in MongoDB
* User authentication with JWT
* Password hashing with bcrypt
* Rich text editing with Flutter Quill
* Real-time document updates with Socket.IO
* Document-specific Socket.IO rooms
* Automatic document saving
* Cross-platform Flutter frontend

## Tech stack

### Frontend
* Flutter
* Dart
* Riverpod
* Flutter Quill
* Socket.IO Client
* Routemaster

### Backend
* Node.js
* Express
* MongoDB
* Mongoose
* Socket.IO
* JWT
* bcrypt

## Project structure

```text
Realtime-Document-Editor/

├── backend/
│   ├── src/
│   │   ├── config/
│   │   ├── controllers/
│   │   ├── middlewares/
│   │   ├── models/
│   │   ├── routes/
│   │   ├── socket/
│   │   ├── app.js
│   │   └── server.js
│   └── package.json
│
└── frontend/
    ├── lib/
    │   ├── clients/
    │   ├── models/
    │   ├── providers/
    │   ├── repositories/
    │   ├── screens/
    │   ├── services/
    │   └── main.dart
    └── pubspec.yaml
```

## How real-time editing works

Each document gets its own Socket.IO room. When a user makes a change in Quill, the frontend sends the change to the server. The server broadcasts it to the other clients currently editing the same document.

The document is also periodically saved back to MongoDB, so the latest content is persisted instead of only existing in the active Socket.IO session.

## Getting started

### 1. Clone the repo
```bash
git clone https://github.com/isamm-ali/Realtime-Document-Editor.git
cd Realtime-Document-Editor
```

### 2. Start the backend
```bash
cd backend
npm install
```

Create a `.env` file in `backend/`:
```env
PORT=5000
MONGODB_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret
```

Then run:
```bash
npm start
```

### 3. Run the Flutter app
From the `frontend/` directory:
```bash
flutter pub get
flutter run
```

The current Socket.IO client is configured to connect to `http://localhost:5000`, so update the host in `frontend/lib/clients/socket_client.dart` when running the app against a remote backend or a physical device.

## Current status
This is a working version of the core editor rather than a finished Google Docs clone. The main document flow and real-time editing pipeline are implemented, while features such as the actual sharing/invite flow are still being built.

## Why I built it
I wanted to understand what sits behind a collaborative editor instead of only building a text editor UI. The project covers authentication, REST APIs, database persistence, Flutter state management and WebSocket-based synchronization in one codebase.

## License
No license has been added yet.
