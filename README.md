# Quorum

**Everyone is hungry. Nobody wants to choose.**

Quorum is a shared lunch decision room for real groups with real constraints.
Instead of returning another generic restaurant list, it collects each person's
hard limits—diet, budget, walking time, dislikes, and hard stops—then checks
current web evidence and produces a short, explainable shortlist the group can
actually agree on.

[Try the live app](https://quorum-lunch.onrender.com) ·
[Open the Builder Loft demo room](https://quorum-lunch.onrender.com/rooms/builder-loft)

![Quorum landing page](quorum/app/assets/images/quorum/hero-table.png)

## Hackathon track

**Real-Time Intelligence** — Quorum reasons over information that changes
throughout the day: opening hours, menus, prices, dietary options, location, and
walking feasibility.

## How You.com powers it

Quorum uses the You.com platform as a staged research pipeline:

1. **Search API** discovers current candidate restaurants and relevant pages.
2. **Contents API** extracts readable evidence from menus and restaurant pages.
3. **Research API** synthesizes the evidence against the room's participant
   constraints and returns a ranked, citation-backed decision.

The Rails orchestrator validates and stores candidates, per-person assessments,
rejection reasons, and sources. The UI keeps this reasoning visible instead of
hiding it behind a single generated answer.

The public deployment uses a clearly labeled demo provider so the judging flow
remains reliable without spending API credits. To run live research, provide a
`YDC_API_KEY` and disable demo mode.

## Stack

- Ruby on Rails 8.1, PostgreSQL, Puma
- ERB, Hotwire (Turbo + Stimulus)
- Tailwind CSS 4 and DaisyUI 5 with custom branding
- Faraday clients for You.com Search, Contents, and Research APIs
- Render Blueprint with a managed PostgreSQL database

## Local setup

Requirements: Ruby 3.3.11, Node.js 22, and PostgreSQL.

```sh
cd quorum
bundle install
npm install
bin/rails db:prepare db:seed
DEMO_MODE=true bin/dev
```

Open `http://localhost:3000`. The seeded decision room is available at
`http://localhost:3000/rooms/builder-loft`.

For live You.com research:

```sh
export YDC_API_KEY="your-key"
unset DEMO_MODE
bin/dev
```

## Verification

```sh
cd quorum
bin/rails test
npm run build
npm run build:css
bin/rails zeitwerk:check
```

The automated suite stubs You.com HTTP boundaries, so tests do not spend API
credits.

## Deployment

The repository-root [`render.yaml`](render.yaml) provisions the Rails web
service and PostgreSQL database. See [`quorum/README.md`](quorum/README.md) for
additional implementation and deployment notes.
