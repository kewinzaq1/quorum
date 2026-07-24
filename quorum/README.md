# Quorum

Quorum helps a real group make a lunch decision without turning the break into
another meeting. It captures each person’s hard constraints, checks nearby
restaurants against current web evidence, and returns a short, sourced decision
room where the group can lock a choice and keep a backup.

## Stack

- Rails 8.1, PostgreSQL, Puma
- ERB, Turbo, Stimulus
- Tailwind CSS 4 with DaisyUI 5
- You.com Search, Contents, and asynchronous Research APIs
- Render web service and managed PostgreSQL

## Local setup

Requirements: Ruby 3.3.11, Node 22, and PostgreSQL.

```sh
bundle install
npm install
bin/rails db:prepare db:seed
bin/dev
```

Open `http://localhost:3000`. The seeded, visibly labeled offline room is at
`/rooms/builder-loft`.

For live research, run `export YDC_API_KEY=...` before starting the server. If
you deliberately want fixture data for local visual work, run
`export DEMO_MODE=true`. `.env.example` documents all runtime variables; Rails
does not load that file automatically.

## Test and verify

```sh
bin/rails test
npm run build
npm run build:css
bin/rails assets:precompile
```

All You.com calls are stubbed in tests; the suite never spends API credits.

## Render

The repository-root `render.yaml` provisions one Ruby web service and one
PostgreSQL database. In Render, set `RAILS_MASTER_KEY` from
`config/master.key`. The first deployment intentionally enables the visibly
labeled demo provider so a fresh Blueprint works without spending API credits.
To enable live research, add `YDC_API_KEY` as a secret and set `DEMO_MODE=false`.
The build script installs dependencies, compiles assets, precompiles Rails
assets, and runs migrations.
