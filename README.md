# Project Repository

This repository contains a Node.js Express backend for a database visualizer/manager.

Quickstart:
1. cd database/db_visualizer
2. cp .env.example .env  # fill in values as needed
3. npm install
4. npm start

Endpoints:
- GET /health -> { status: "ok" }
- GET /api/ping -> { message: "pong" }
- GET /api/databases -> Supported DB types
- Docs: /docs (Swagger UI)

Notes:
- Requires Node.js v18+.
- Do not commit secrets. Use the .env file (not tracked).
- The backend uses CORS and security headers; set CORS_ORIGIN in .env if needed.