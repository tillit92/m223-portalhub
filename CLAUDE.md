# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project state

Rails 8.1 app (Ruby 4.0.6, see `.ruby-version`) for the module m223 "Rick and Morty Portalhub". Tickets 01 to 10 are done (01 to 06 the MVP, 07 to 10 added because the Kompetenznachweis asks for them): login/logout (Rails built-in authentication, no password reset), `User` with role, `Portal` and `Booking`, the portal overview (root) and details page, reserving a seat (`Portal#reserve_seat_for`, the locking core), "Meine Reservierungen" with cancelling, the admin area for Rick (`Admin::` namespace behind `Admin::BaseController`: Portal CRUD and cancelling bookings), the Aktivitätsprotokoll (`Activity`, written by the controllers), the user profile, user management for Rick and German error pages (`public/*.html`), seeds and the shared design (`app/assets/stylesheets/`). The README and `docs/umsetzung.md` (state, deviations, checks) are written. Still open, and needs a human: trying the app in Firefox and Safari (see `docs/umsetzung.md`). The work was planned in `.scratch/portalhub-mvp/` (spec plus six tickets). The requirements live in `docs/spec.md` (German); read it before building features.

## Domain (from `docs/spec.md`)

Multiuser app where travelers reserve a seat on a portal to another dimension. The UI and user-facing messages are German, in a Rick and Morty tone (e.g. "Portal voll! ... Versuch es mit einer anderen Dimension, Morty!").

- **Entities**: `User` (name, email_address, password_digest, role), `Portal` (name, dimension, departure_time, capacity), `Booking` (user_id, portal_id), `Activity` (user_id, user_name, action, details). Free seats = `capacity` minus the number of bookings; there is no stored counter.
- **Roles**: traveler (browse portals, book, view/cancel own bookings) and admin "Rick" (CRUD on portals, manage bookings). Only logged-in users may book; non-admins hitting the admin area see "Berechtigung fehlt". Portal capacity must be at least 1 (validation message "Kapazität muss mind. 1 sein").
- **Core invariant**: bookings per portal must never exceed `capacity`, even when several users book the last seat at the same time. The spec asks for a transaction plus a lock on the portal, re-checking free seats inside it; a full portal saves no booking and shows 0 free seats with the button disabled. Cancelling asks for confirmation first.
- **Locking on SQLite**: `Portal#lock!` (`SELECT ... FOR UPDATE`) does nothing on SQLite. Serialization comes from the Rails 8 SQLite adapter starting every write transaction with `BEGIN IMMEDIATE` (`default_transaction_mode: :immediate`), so the free-seat check has to run inside the same `transaction` block as the insert. Test this with concurrent requests, not just a sequential unit test.
- **Auth columns**: the ERM says `email` and `password`, the code uses `email_address` and `password_digest` (Rails authentication generator, see the deviations in `docs/spec.md`). Demo users come from `db/seeds.rb`: Rick is the admin and everyone shares one password (see the seeds).

## Commands

- Setup: `bin/setup` (installs gems, prepares the DB, starts the server; add `--skip-server` to only prepare)
- Run dev server: `bin/dev` (just `rails server`, there is no Procfile / asset watcher)
- Full local CI: `bin/ci` (defined in `config/ci.rb`: setup, rubocop, bundler-audit, importmap audit, brakeman, `rails test`, seed replant)
- Tests: `bin/rails test`
- Single test file / line: `bin/rails test test/models/foo_test.rb` / `bin/rails test test/models/foo_test.rb:12`
- System tests: there are none (out of scope, see `.scratch/portalhub-mvp/spec.md`), so `bin/rails test:system` fails and the GitHub workflow has no such job. Browser behaviour is covered by `script/browser_check.mjs`.
- Browser check with real JavaScript (Turbo confirm dialogs): `node script/browser_check.mjs` (Node 22+, a Chromium browser, running dev server; it changes dev data, run `bin/rails db:seed` afterwards)
- Lint: `bin/rubocop` (rubocop-rails-omakase, config in `.rubocop.yml`); autofix with `bin/rubocop -a`
- Security: `bin/brakeman`, `bin/bundler-audit`, `bin/importmap audit`
- Migrations: `bin/rails db:migrate`

## Architecture

- **Frontend**: Hotwire without a JS build step. Propshaft serves assets, importmap-rails manages JS (`config/importmap.rb`, `app/javascript/`), Turbo + Stimulus handle interactivity. Stimulus controllers in `app/javascript/controllers/` are auto-registered through `index.js`; `hello_controller.js` is just the generator sample.
- **Database**: SQLite everywhere (`storage/*.sqlite3`). In production Rails uses four separate SQLite databases: primary plus `cache`, `queue` and `cable` for Solid Cache / Solid Queue / Solid Cable. Their schemas are `db/cache_schema.rb`, `db/queue_schema.rb` and `db/cable_schema.rb`, and their migrations live in `db/{cache,queue,cable}_migrate`. Development and test use a single database and no Solid infrastructure.
- **Tests**: Minitest with fixtures (`fixtures :all`) and `parallelize(workers: :number_of_processors)` in `test/test_helper.rb`. Tests run in parallel, so don't rely on shared state between them.
- **Deployment**: Docker image (`Dockerfile`) deployed with Kamal (`.kamal/`, `config/deploy.yml`), Thruster in front of Puma. `bin/jobs` runs the Solid Queue worker.
- **PWA**: `app/views/pwa/` holds the manifest and service worker templates (there are no routes for them).

## Agent skills

### Issue tracker

Issues and specs live as local markdown files under `.scratch/<feature>/`. See `docs/agents/issue-tracker.md`.

### Triage labels

Default vocabulary: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.

# PortalHub

Multiuser-Reservierungsapp für interdimensionale Portale (Rick and Morty), gebaut mit Ruby on Rails und SQLite.

## Projektkontext

@docs/spec.md
@docs/wegleitung.md

Die vollständige Anforderungsanalyse steht in `docs/spec.md`.
Eine eigene Konventionsdatei gibt es nicht: Code-Konventionen sind die Rails-Standards (Rubocop Omakase, Rails-Namensgebung und -Generatoren) plus die Vorgaben der Wegleitung.
`docs/wegleitung.md` enthält die Modul-Vorgaben (Bewertungskriterien): u.a. dass automatisierte Tests explizit die zentrale Fachregel (Locking beim letzten Platz) sowie erlaubte/verweigerte Zugriffe prüfen müssen, dass `docs/` alle Bilder und Markdown-Doku enthalten muss, und wie `README.md` aufgebaut sein soll (Tech-Stack, Setup, Start-/Testbefehle, Demo-Konten). Diese Vorgaben sind beim Planen, Implementieren und beim Schreiben von README/Doku verbindlich einzuhalten.

## Diagramme

Diese Bilder zeigen ERM, Breadboards und Mockups im Detail und sollten vor UI- bzw. Datenmodell-Arbeit angesehen werden:

- `docs/diagrams/erm.svg` – Entity-Relationship-Model des genehmigten Antrags (User, Portal, Booking); `docs/diagrams/erm-umgesetzt.svg` zeigt dasselbe mit den umgesetzten Spaltennamen (`email_address`, `password_digest`) und gilt für den Code
- `docs/diagrams/breadboard.svg` – Klick-/Ablaufdiagramm durch alle Seiten inkl. Server-Prüfung
- `docs/diagrams/wireframes.svg` – UI-Mockups aller Screens

Bei Fragen zu Datenmodell oder UI-Layout diese Dateien mit @docs/diagrams/<datei>.svg in den Kontext holen (z.B. `@docs/diagrams/erm.svg Erklär mir die Beziehungen`).

## Wichtigster technischer Punkt

Bei gleichzeitigen Buchungen um den letzten freien Platz eines Portals darf nur eine Reservierung erfolgreich sein. Das erfordert eine Transaktion mit Locking (z.B. `with_lock` in Rails), nicht nur eine einfache Validierung.