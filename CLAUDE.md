# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project state

Freshly generated Rails 8.1 app (Ruby 4.0.6, see `.ruby-version`) for the module m223 "Rick and Morty Portalhub". As of now there is no domain code: no models, no controllers beyond `ApplicationController`, and `config/routes.rb` only has the `/up` health check. The README is still the Rails default. The requirements live in `docs/spec.md` (German); read it before building features.

## Domain (from `docs/spec.md`)

Multiuser app where travelers reserve a seat on a portal to another dimension. The UI and user-facing messages are German, in a Rick and Morty tone (e.g. "Portal voll! ... Versuch es mit einer anderen Dimension, Morty!").

- **Entities**: `User` (name, email, password, role), `Portal` (name, dimension, departure_time, capacity), `Booking` (user_id, portal_id). Free seats = `capacity` minus the number of bookings; there is no stored counter.
- **Roles**: traveler (browse portals, book, view/cancel own bookings) and admin "Rick" (CRUD on portals, manage bookings). Only logged-in users may book; non-admins hitting the admin area see "Berechtigung fehlt". Portal capacity must be at least 1 (validation message "Kapazität muss mind. 1 sein").
- **Core invariant**: bookings per portal must never exceed `capacity`, even when several users book the last seat at the same time. The spec asks for a transaction plus a lock on the portal, re-checking free seats inside it; a full portal saves no booking and shows 0 free seats with the button disabled. Cancelling asks for confirmation first.
- **Locking on SQLite**: `Portal#lock!` (`SELECT ... FOR UPDATE`) does nothing on SQLite. Serialization comes from the Rails 8 SQLite adapter starting every write transaction with `BEGIN IMMEDIATE` (`default_transaction_mode: :immediate`), so the free-seat check has to run inside the same `transaction` block as the insert. Test this with concurrent requests, not just a sequential unit test.
- `password` is auth data: `bcrypt` is commented out in the `Gemfile`, so `has_secure_password` needs it enabled first.

## Commands

- Setup: `bin/setup` (installs gems, prepares the DB, starts the server; add `--skip-server` to only prepare)
- Run dev server: `bin/dev` (just `rails server`, there is no Procfile / asset watcher)
- Full local CI: `bin/ci` (defined in `config/ci.rb`: setup, rubocop, bundler-audit, importmap audit, brakeman, `rails test`, seed replant)
- Tests: `bin/rails test`
- Single test file / line: `bin/rails test test/models/foo_test.rb` / `bin/rails test test/models/foo_test.rb:12`
- System tests (Capybara + Selenium, run separately in GitHub CI, not part of `bin/ci`): `bin/rails test:system`
- Lint: `bin/rubocop` (rubocop-rails-omakase, config in `.rubocop.yml`); autofix with `bin/rubocop -a`
- Security: `bin/brakeman`, `bin/bundler-audit`, `bin/importmap audit`
- Migrations: `bin/rails db:migrate`

## Architecture

- **Frontend**: Hotwire without a JS build step. Propshaft serves assets, importmap-rails manages JS (`config/importmap.rb`, `app/javascript/`), Turbo + Stimulus handle interactivity. Stimulus controllers in `app/javascript/controllers/` are auto-registered through `index.js`; `hello_controller.js` is just the generator sample.
- **Database**: SQLite everywhere (`storage/*.sqlite3`). In production Rails uses four separate SQLite databases: primary plus `cache`, `queue` and `cable` for Solid Cache / Solid Queue / Solid Cable. Their schemas are `db/cache_schema.rb`, `db/queue_schema.rb` and `db/cable_schema.rb`, and their migrations live in `db/{cache,queue,cable}_migrate`. Development and test use a single database and no Solid infrastructure.
- **Tests**: Minitest with fixtures (`fixtures :all`) and `parallelize(workers: :number_of_processors)` in `test/test_helper.rb`. Tests run in parallel, so don't rely on shared state between them.
- **Deployment**: Docker image (`Dockerfile`) deployed with Kamal (`.kamal/`, `config/deploy.yml`), Thruster in front of Puma. `bin/jobs` runs the Solid Queue worker.
- **PWA**: `app/views/pwa/` holds the manifest and service worker templates (routes for them are commented out in `config/routes.rb`).

## Agent skills

### Issue tracker

Issues and specs live as local markdown files under `.scratch/<feature>/`. See `docs/agents/issue-tracker.md`.

### Triage labels

Default vocabulary: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.
