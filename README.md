# PortalHub

Multiuser-Webapplikation im Stil von Rick and Morty (Modul M223). Reisende sehen Portale zu verschiedenen Dimensionen und reservieren einen Platz für die Reise. Ein Portal nimmt nie mehr Reservierungen an, als es Plätze hat, auch wenn mehrere Reisende gleichzeitig um den letzten Platz konkurrieren. Rick (Admin) verwaltet die Portale.

![Portalübersicht](docs/screenshots/03-portaluebersicht.png)

Was und warum (Anforderungen, ERM, Breadboards, Locking-Konzept): [docs/spec.md](docs/spec.md). Stand der Umsetzung und Prüfung der Anforderungen: [docs/umsetzung.md](docs/umsetzung.md). Diese README erklärt nur, wie die Applikation ausgeführt wird.

## Technologie-Stack

| Bereich | Technologie | Version |
| --- | --- | --- |
| Sprache | Ruby | 4.0.6 (siehe `.ruby-version`) |
| Framework | Ruby on Rails | 8.1.3.1 |
| Datenbank | SQLite 3 (Gem `sqlite3`) | 2.9.6 |
| Webserver | Puma | 8.0.2 |
| Frontend | Hotwire (Turbo 2.0.23, Stimulus 1.3.4), Propshaft 1.3.2, importmap-rails 2.2.3, kein JavaScript-Build | |
| Anmeldung | Rails-Authentifizierung mit `has_secure_password` (bcrypt 3.1.22) | |
| Tests | Minitest 6.0.6, Fixtures | |
| Qualität | Rubocop (Rails Omakase), Brakeman, bundler-audit | |
| Schrift | Geist und Geist Mono (SIL Open Font License, selbst gehostet) | |

## Voraussetzungen

- Ruby 4.0.6, zum Beispiel über [rbenv](https://github.com/rbenv/rbenv) (`rbenv install 4.0.6`)
- Bundler (kommt mit Ruby) und die SQLite-3-Bibliothek des Betriebssystems
- Ein aktueller Browser: Chrome ab 120, Firefox ab 121 oder Safari ab 17.2. Ältere Browser weist Rails mit `allow_browser :modern` ab.

## Installation und Start

```bash
bin/setup --skip-server   # Gems installieren, Datenbank anlegen, Demo-Daten laden
bin/dev                   # Server starten: http://localhost:3000
```

`bin/setup` legt die Datenbank `storage/development.sqlite3` aus `db/schema.rb` an und lädt beim ersten Mal die Demo-Daten. Ohne `--skip-server` startet es den Server gleich mit.

## Datenbank und Demo-Daten

Vier Tabellen: `users` (mit Rolle `traveler` oder `admin`), `portals`, `bookings` (ein Reisender pro Portal höchstens einmal, dafür gibt es einen Unique-Index) und `sessions` (Anmeldung). Freie Plätze werden nie gespeichert, sondern immer aus Kapazität minus Reservierungen berechnet. Das ERM steht in [docs/spec.md](docs/spec.md).

Die Demo-Daten stehen in `db/seeds.rb` und lassen sich beliebig oft neu laden, ohne Duplikate zu erzeugen:

```bash
bin/rails db:seed
```

Sie enthalten fünf Portale mit Abflugzeiten relativ zu heute: mehrere kommende, ein volles ("Abend-Portal") und ein bereits abgeflogenes ("Gestern-Portal").

## Demo-Konten

Alle Konten haben das Passwort `wubba-lubba`.

| E-Mail | Name | Rolle |
| --- | --- | --- |
| `rick@portalhub.test` | Rick Sanchez | Admin (verwaltet Portale und Reservierungen) |
| `morty@portalhub.test` | Morty Smith | Reisender |
| `summer@portalhub.test` | Summer Smith | Reisender |
| `beth@portalhub.test` | Beth Smith | Reisender |
| `birdperson@portalhub.test` | Birdperson | Reisender |

Eine Selbstregistrierung gibt es nicht. Für den Wettlauf um den letzten Platz melde dich in zwei getrennten Browserfenstern (eines davon privat) als zwei verschiedene Reisende an und reserviere dasselbe Portal.

## Tests

```bash
bin/rails test                                          # alle Tests
bin/rails test test/models/portal_concurrency_test.rb   # die zentrale Fachregel: gleichzeitige Reservierungen
bin/rails test test/integration/admin_access_test.rb:6  # ein einzelner Test (Datei:Zeile)
bin/ci                                                  # alles wie in der Abgabe: Style, Sicherheit, Tests, Seeds
```

Die Tests prüfen die zentrale Fachregel (nie mehr Reservierungen als Plätze, auch bei gleichzeitigen Anfragen) sowie erlaubte und verweigerte Zugriffe für Besucher, Reisende und Admin. Wie die Sperre funktioniert und was die Tests beweisen, steht in [docs/adr/0002-capacity-enforced-with-portal-lock.md](docs/adr/0002-capacity-enforced-with-portal-lock.md).

## Weitere Dokumentation

- [docs/spec.md](docs/spec.md): Anforderungen, ERM, Breadboards, Locking und Transaktionen
- [docs/umsetzung.md](docs/umsetzung.md): erreichter Stand, Abweichungen, Prüfung der Anforderungen, Screens
- [docs/adr/](docs/adr/): Architekturentscheidungen
- [CONTEXT.md](CONTEXT.md): Glossar der Fachbegriffe
