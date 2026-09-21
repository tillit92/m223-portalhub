# M223 – Rick and Morty PortalHub

## Projektidee

PortalHub ist eine Multiuser-Webapplikation, gestaltet im Stil der Welt von Rick and Morty.

Benutzer sehen verschiedene Portale zu unterschiedlichen Dimensionen und können einen Platz für eine Reise durch ein Portal reservieren.

Ein Portal hat eine bestimmte Anzahl verfügbarer Plätze. Wenn alle Plätze reserviert sind, kann kein weiterer Benutzer das Portal buchen.

**Tech-Stack:** Ruby on Rails, SQLite.

## Problemstellung

Rick und Morty reisen ständig durch verschiedene Dimensionen mit ihrer Portal Gun. Wenn mehrere Personen mitreisen möchten, wird schnell unübersichtlich, welches Portal wohin führt und wie viele Plätze noch frei sind.

PortalHub löst das: Benutzer sehen verfügbare Portale und reservieren einen Platz für eine Reise.

Da mehrere Benutzer gleichzeitig ein Portal reservieren können, muss das System sicherstellen, dass nicht mehr Personen ein Portal reservieren, als es Plätze gibt.

## Vision

Eine einfache Plattform, über die Benutzer schnell ein verfügbares Portal auswählen und eine Reise in eine andere Dimension reservieren können. Übersichtlich und einfach zu bedienen.

## Erste MVP-Iteration

Wichtigste funktionale Anforderung: die Reservierung eines Platzes für eine interdimensionale Reise.

Benutzer sehen verfügbare Portale mit Zieldimension, Abflugzeit und Anzahl freier Plätze, und können einen Platz reservieren.

Ein Portal hat eine maximale Kapazität (z.B. 5 Reisende) – nicht mehr Personen dürfen gleichzeitig einen Platz reservieren.

**Kritischer Multiuser-Fall:** Wenn mehrere Reisende gleichzeitig versuchen, den letzten freien Platz zu reservieren, darf nur eine Reservierung erfolgreich sein.

## Anforderungsanalyse

### Funktionale Anforderungen (priorisiert)

1. Benutzer können sich anmelden.
2. Benutzer können verfügbare Portale ansehen.
3. Benutzer sehen die Anzahl der freien Plätze.
4. Benutzer können einen Platz reservieren.
5. Benutzer können ihre Reservierungen ansehen.
6. Benutzer können ihre Reservierungen stornieren.
7. Ein Administrator kann Portale erstellen, bearbeiten und löschen.
8. Ein Portal darf seine maximale Kapazität nicht überschreiten.

### Qualitätsattribute

1. **Benutzerfreundlichkeit:** Portalreservierung soll einfach und übersichtlich sein.
2. **Sicherheit:** Nur eingeloggte Benutzer dürfen Portalreisen reservieren.
3. **Berechtigungen:** Nur Rick/Admin darf Portale erstellen, bearbeiten und löschen.
4. **Zuverlässigkeit:** Die maximale Kapazität eines Portals darf auch bei mehreren gleichzeitigen Reservierungen nicht überschritten werden.
5. **Reaktionszeit:** Die wichtigsten Seiten sollen innerhalb weniger Sekunden geladen werden.
6. **Kompatibilität:** PortalHub soll mit gängigen Webbrowsern funktionieren.

### Benutzerrollen

1. **Interdimensionaler Reisender:** Kann Portale ansehen, freie Plätze prüfen, Reisen reservieren und eigene Reservierungen verwalten.
2. **Rick / Admin:** Kann Portale erstellen, bearbeiten und löschen sowie Reservierungen verwalten.

## ERM (Entity-Relationship-Model)

**USER**
- id (PK)
- name
- email
- password
- role

**PORTAL**
- id (PK)
- name
- dimension
- departure_time
- capacity

**BOOKING**
- id (PK)
- user_id (FK)
- portal_id (FK)

**Beziehungen:** USER 1—n BOOKING, PORTAL 1—n BOOKING

**Regel:** Anzahl BOOKING pro PORTAL ≤ PORTAL.capacity | freie Plätze = capacity − Anzahl Bookings

## Breadboards

### 1. Startseite / Login
- Feld: E-Mail
- Feld: Passwort
- [ Anmelden ]

### 2. Portalübersicht
- Nav: Reserv. | Admin | Logout
- Liste: Name / Dimension / Zeit, "X von Y Plätzen frei"
- Link: Meine Reservierungen
- [ Details ] → Portal auswählen

### 3. Portal-Detail
- Name, Dimension, Abflugzeit
- Kapazität / reserviert / frei
- Link: Zurück
- [ Platz reservieren ]

**Prüfung (Server):** Transaktion + Sperre auf Portal → freie Plätze > 0?
- JA → Buchung speichern, "Platz reserviert", freie Plätze sinken für alle
- NEIN → "Portal ist inzwischen voll" (Anzeige: 0 Plätze frei, Reservieren-Button inaktiv), keine Buchung gespeichert

### 4. Meine Reservierungen
- OK-Meldung: "Platz reserviert"
- Liste: eigene Buchungen
- [ Stornieren ] (mit Rückfrage vor dem Stornieren)
- Link: Zurück zur Übersicht
- Leerzustand: "Du hast noch keine Reservierung."

### 5. Admin-Bereich (Rick)
- Nav: Portale | Logout
- Tabelle: Name, Dimension, Zeit, Kapazität, Reserviert
- [ Bearbeiten ] [ Löschen ] [ Reservierungen ]
- [ + Neues Portal ]
- Nur für Rolle = admin erreichbar. Traveler sieht: "Berechtigung fehlt".

### 5b. Admin: Portal-Formular
- Felder: Name, Dimension, Abflugzeit, Kapazität
- [ Speichern ] [ Abbrechen ]
- Validierung: "Kapazität muss mind. 1 sein"

## Fat-Marker-Sketches: Transaktionen und Locking

Bei einer Portalreservierung muss sichergestellt werden, dass die maximale Anzahl an Reisenden nicht überschritten wird.

Beispiel: Bei einem Portal ist nur noch ein Platz frei, und zwei Reisende versuchen gleichzeitig, diesen Platz zu reservieren – nur eine Reservierung darf erfolgreich sein.

Durch eine geeignete Transaktion bzw. Sperrung (Locking) wird verhindert, dass beide Benutzer den gleichen letzten Platz reservieren können.

## Beispiel für ein Portal

**Portal C-137**
- Ziel: Dimension C-137
- Abflug: 14:30 Uhr
- Kapazität: 5 Reisende
- Bereits reserviert: 3
- Freie Plätze: 2

Nach Klick auf "Portal reservieren" bei vollem Portal:

> **Portal voll!** Dieses Portal hat bereits seine maximale Kapazität erreicht. Versuch es mit einer anderen Dimension, Morty!