# Pchook

A self-hosted book tracker with AI-powered cover scanning. Snap a photo of a book cover, and the app extracts all metadata automatically — title, authors, genre, synopsis, awards, public ratings, and more.

Built with a **TypeScript backend** (Nitro + Bun) and a **SwiftUI iOS app**.

## Features

- **Cover scanning** — point your camera at a book cover to add it to your library instantly (Claude Vision + Gemini enrichment + Open Library lookup)
- **Library management** — filter by status (to-read / read), genre, sort by rating, title, date added, awards
- **Reviews & ratings** — rate books 1-5 stars, write personal notes, track read dates
- **Series tracking** — browse series with position tracking, navigate between books in a series
- **Book suggestions** — AI-generated recommendations based on your reading history
- **URL import** — share a book URL from Safari to add it via the iOS Share Extension
- **Dashboard** — reading stats, recently added books, favorites, awards from your library

## Prerequisites

| Tool | Install |
|------|---------|
| [Bun](https://bun.sh/) | `curl -fsSL https://bun.sh/install \| bash` |
| [Xcode](https://developer.apple.com/xcode/) | Mac App Store |

## Setup

**1. Clone and install**

```bash
git clone https://github.com/moifort/pchook.git
cd pchook
bun install
```

**2. Configure API keys**

Copy the example env file and fill in your keys:

```bash
cp .env.example .env
```

| Variable | Required | Purpose |
|----------|----------|---------|
| `NITRO_ANTHROPIC_API_KEY` | Yes | Claude API — extracts book info from cover photos |
| `NITRO_GOOGLE_API_KEY` | Yes | Gemini API — enriches metadata (awards, synopsis) |
| `NITRO_HARDCOVER_API_TOKEN` | No | Hardcover API — community ratings and cover images |
| `NITRO_API_TOKEN` | No | Protects the API with a bearer token |
| `NITRO_SENTRY_DSN` | No | Error tracking via Sentry |

Then create the iOS secrets file:

```bash
cp ios/Pchook/Shared/Secrets.swift.example ios/Pchook/Shared/Secrets.swift
```

Edit `ios/Pchook/Shared/Secrets.swift` with the same API token and your server URL.

**3. Start the backend**

```bash
bun run dev
```

Server runs at `http://localhost:3000`. Verify: `http://localhost:3000/health`

**4. Run the iOS app**

```bash
open ios/Pchook.xcodeproj
```

Set your Development Team in Signing & Capabilities, pick a simulator, and hit Run.

## Deploy with Docker

```bash
docker compose up -d
```

The backend uses file-based storage, persisted in `./data`. Set your environment variables in a `.env` file next to the compose file.

A [CasaOS](https://casaos.io/)-compatible compose file is also available (`docker-compose.casaos.yml`).

## Tech stack

**Backend:** Nitro, Bun, TypeScript, Zod, ts-pattern, file-based storage, Sentry
**iOS:** SwiftUI, iOS 26+, Swift 6, strict concurrency
**AI:** Claude Vision (cover analysis), Gemini 2.0 Flash (metadata enrichment), Open Library (ISBN lookup)
**Deploy:** Docker, GitHub Actions CI
