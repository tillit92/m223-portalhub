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

1. **Datenkonsistenz:** Versuchen zehn Reisende gleichzeitig, den letzten freien Platz eines Portals zu reservieren, wird genau eine Reservierung gespeichert. Geprüft durch einen automatisierten Test mit parallelen Anfragen.
2. **Berechtigungen:** Ruft ein Reisender eine Admin-Seite auf (Portale erstellen, bearbeiten, löschen), erscheint "Berechtigung fehlt" und es werden keine Daten verändert. Ein nicht angemeldeter Benutzer wird bei jeder geschützten Seite zum Login geleitet und kann nicht reservieren. Geprüft durch automatisierte Integrationstests für erlaubte und verweigerte Zugriffe.
3. **Reaktionszeit:** Die Portalübersicht mit 100 Portalen wird bei zehn gleichzeitigen Anfragen innerhalb von 2 Sekunden ausgeliefert. Geprüft mit einem Lasttest.
4. **Bedienbarkeit:** Ein angemeldeter Reisender erreicht die Reservierung eines Platzes von der Portalübersicht aus in höchstens zwei Klicks (Details, Platz reservieren) und erhält eine Bestätigung. Geprüft durch manuellen Durchlauf.
5. **Kompatibilität:** Login, Portalübersicht, Reservierung und Stornierung funktionieren in den aktuellen Versionen von Chrome, Firefox und Safari. Geprüft durch manuellen Durchlauf.

### Benutzerrollen

1. **Interdimensionaler Reisender:** Kann Portale ansehen, freie Plätze prüfen, Reisen reservieren und eigene Reservierungen verwalten.
2. **Rick / Admin:** Kann Portale erstellen, bearbeiten und löschen sowie Reservierungen verwalten.

## ERM (Entity-Relationship-Model)

**USER**
- id (PK)
- name
- email_address (im Antrag: email)
- password_digest (im Antrag: password, gespeichert wird nur der Hash)
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

Zusätzlich gibt es die Tabelle `sessions` (angemeldete Benutzer, vom Rails-Authentifizierungsgenerator) und die Tabelle `activities` (Aktivitätsprotokoll, siehe unten). Beide stehen nicht im ERM des Antrags. Das Diagramm des Antrags ist `docs/diagrams/erm.svg`, das Diagramm mit den umgesetzten Spaltennamen `docs/diagrams/erm-umgesetzt.svg`.

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

## Locking und Transaktionen

Bei einer Portalreservierung muss sichergestellt werden, dass die maximale Anzahl an Reisenden nicht überschritten wird.

Beispiel: Bei einem Portal ist nur noch ein Platz frei, und zwei Reisende versuchen gleichzeitig, diesen Platz zu reservieren – nur eine Reservierung darf erfolgreich sein.

Durch eine geeignete Transaktion bzw. Sperrung (Locking) wird verhindert, dass beide Benutzer den gleichen letzten Platz reservieren können.

Ein einziges Konzept deckt beide Funktionen ab, die es benötigen: Sowohl das **Reservieren** als auch das **Ändern der Kapazität** durch Rick laufen in einer Transaktion mit Sperre auf dem Portal (`Portal#with_lock`). Die freien Plätze werden erst innerhalb dieser Transaktion gezählt. Ändert Rick die Kapazität, während jemand reserviert, wird die spätere der beiden Aktionen erst nach der ersten ausgeführt und gegebenenfalls mit einer verständlichen Meldung abgelehnt (Portal voll, bzw. Kapazität nicht kleiner als die Anzahl Reservierungen). Die Begründung der Wahl steht in `docs/adr/0002-capacity-enforced-with-portal-lock.md`.

## Beispiel für ein Portal

**Portal C-137**
- Ziel: Dimension C-137
- Abflug: 14:30 Uhr
- Kapazität: 5 Reisende
- Bereits reserviert: 3
- Freie Plätze: 2

Nach Klick auf "Portal reservieren" bei vollem Portal:

> **Portal voll!** Dieses Portal hat bereits seine maximale Kapazität erreicht. Versuch es mit einer anderen Dimension, Morty!

## Präzisierungen und Abweichungen nach der Genehmigung

Diese Regeln wurden nach der Genehmigung des Projektantrags geklärt. Begriffe sind in `CONTEXT.md` definiert.

### Fachregeln

- **Portal:** Ein Portal ist ein einmaliger Abflug mit Datum und Uhrzeit, keine wiederkehrende Verbindung (`docs/adr/0001-portal-is-a-one-off-departure.md`). Die Wireframes zeigen der Kürze halber nur die Uhrzeit.
- **Vergangene Portale:** Nach der Abflugzeit kann ein Portal weder reserviert noch storniert werden. Es verschwindet aus der Portalübersicht der Reisenden. Rick sieht es weiterhin, und "Meine Reservierungen" zeigt es weiterhin an.
- **Eine Reservierung pro Person:** Ein Reisender kann pro Portal höchstens einen Platz reservieren (Meldung: "Du hast bereits einen Platz in diesem Portal.").
- **Benutzer:** Es gibt keine Selbstregistrierung. Rick und einige Reisende werden über die Seed-Daten angelegt. Die Rolle ist `traveler` (Standard) oder `admin`.
- **Portal löschen:** Rick kann ein Portal mit Reservierungen nach einer Rückfrage ("Es gibt X Reservierungen") löschen. Die Reservierungen werden mitgelöscht.
- **Kapazität ändern:** Die Kapazität darf nie kleiner sein als die aktuelle Anzahl Reservierungen. Die Meldung nennt diese Zahl.
- **Reservierungen verwalten (Rick):** Rick sieht pro Portal, wer reserviert hat, und kann fremde Reservierungen stornieren. Er kann nicht für andere reservieren, aber wie ein Reisender selbst reservieren.
- **Stornieren:** Eine stornierte Reservierung wird gelöscht, der Platz ist sofort wieder frei. Es gibt keine Historie.
- **Navigation:** Der Link "Admin" wird nur für Rick angezeigt. Die Berechtigungsprüfung auf dem Server bleibt zusätzlich bestehen.

### Erweiterungen nach dem Antrag

Der Kompetenznachweis verlangt Funktionen, die im Antrag nicht standen. Sie wurden nachträglich umgesetzt:

- **Benutzerprofil:** Jeder angemeldete Benutzer sieht unter "Profil" seine Daten (Name, E-Mail, Rolle) und ändert Name, E-Mail und Passwort. Für ein neues Passwort ist das aktuelle nötig, es hat mindestens 8 Zeichen und muss wiederholt werden. Danach enden die anderen Sitzungen des Benutzers. Man kann nur das eigene Profil ändern, und die Rolle lässt sich dort nicht ändern.
- **Benutzerverwaltung:** Rick sieht alle Benutzer mit Rolle und Anzahl Reservierungen, legt Benutzer an (Startpasswort mindestens 8 Zeichen), ändert Name, E-Mail, Rolle und optional das Passwort und löscht Benutzer. Weil es keine Selbstregistrierung gibt, ist das der Weg für neue Reisende und Admins. Rick kann sich nicht selbst löschen und seine eigene Rolle nicht ändern. Zusätzlich gilt im Modell: Der letzte Admin kann nie herabgestuft oder gelöscht werden, auch nicht von einem anderen Admin und auch nicht, wenn zwei Admins gleichzeitig handeln. Setzt Rick ein neues Passwort oder ändert eine Rolle, enden die Sitzungen dieses Benutzers. Beim Löschen (mit Rückfrage und Anzahl Reservierungen) werden die Reservierungen und Sitzungen des Benutzers mitgelöscht, die Plätze werden frei.
- **Aktivitätsprotokoll:** Rick sieht unter "Protokoll" die letzten 200 Einträge, die neuesten zuerst, und kann nach Aktion und Benutzer filtern: Anmeldung, fehlgeschlagene Anmeldung (mit der versuchten E-Mail), Abmeldung, Reservierung, Stornierung (auch durch Rick, mit beiden Namen), Änderungen an Portalen (mit den geänderten Werten), Benutzern und Profilen. Eine abgelehnte Aktion schreibt keinen Eintrag. Passwörter werden nie geschrieben. Bei einer fehlgeschlagenen Anmeldung steht die versuchte E-Mail nur dann im Eintrag, wenn sie wie eine E-Mail-Adresse aussieht, weil manche Leute ihr Passwort ins falsche Feld tippen. Lässt sich ein Eintrag nicht schreiben (zum Beispiel weil die Datenbank gerade beschäftigt ist), wird das nur im Server-Log vermerkt, damit eine bereits gelungene Aktion nicht mit einer Fehlerseite endet. Der Name des Benutzers wird zum Zeitpunkt des Eintrags gespeichert, deshalb bleiben Einträge nach dem Löschen oder Umbenennen lesbar.
- **Live-Aktualisierung:** Ändert jemand etwas, aktualisieren sich die offenen Seiten der anderen von selbst, ohne Neuladen. Wenn Morty reserviert, sinkt bei Rick die Zahl der freien Plätze und Mortys Aktion erscheint im Protokoll. Live sind die Portalübersicht, die Detailseite, "Meine Reservierungen", die Admin-Tabellen (Portale, Reservierungen, Benutzer) und das Protokoll. Formulare, das Profil und die Anmeldeseite sind bewusst nicht live, damit niemand beim Tippen etwas verliert. Der Server sendet nur ein Signal "schau nochmal hin", nie fertige Seiteninhalte, und jeder Browser lädt seine Seite selbst mit seiner eigenen Anmeldung (siehe `docs/adr/0003-live-updates-as-refresh-signals.md`). Nur angemeldete Benutzer können die Live-Verbindung öffnen.
- **Avatare:** Jeder Benutzer kann in seinem Profil ein Bild aus einer festen Auswahl wählen (Rick, Morty, Summer, Beth, Birdperson) oder keines. Es gibt bewusst keinen Upload, die Bilder gehören zur Applikation. Ohne Bild erscheinen die Initialen im Kreis. Rick kann in der Benutzerverwaltung jedem Benutzer ein Bild zuweisen. Das Bild steht neben dem Namen in der Navigation, in der Benutzerliste und im Protokoll.
- **Fehlerseiten:** 404, 422, 500, 400 und die Seite für zu alte Browser sind deutsch, im Design der Applikation und führen (wo sinnvoll) zurück zur Übersicht.

**Breadboards der Erweiterungen** (als Text, die handgezeichneten Skizzen des Antrags bleiben unverändert; die Bildschirme sind in `docs/umsetzung.md` als Screenshots abgebildet):

6. **Profil** (Link: der eigene Name in der Navigation)
   - Daten: Name, E-Mail, [ Speichern ]
   - Passwort: Aktuelles Passwort, Neues Passwort, Wiederholung, [ Passwort ändern ]
   - Fehler stehen am Feld, Erfolg: "Profil gespeichert." bzw. "Passwort geändert."
7. **Admin: Benutzer** (Navigation im Admin-Bereich: Portale | Benutzer | Protokoll)
   - Tabelle: Name, E-Mail, Rolle, Reservierungen, [ Bearbeiten ] [ Löschen ] (beim eigenen Konto ohne Löschen), [ + Neuer Benutzer ]
   - Formular: Name, E-Mail, Rolle (beim eigenen Konto gesperrt), Passwort, [ Speichern ] [ Abbrechen ]
8. **Admin: Protokoll**
   - Filter: Aktion, Benutzer, [ Filtern ] [ Zurücksetzen ]
   - Tabelle: Zeit, Wer, Aktion, Beschreibung. Leerzustand: "Noch nichts passiert."

### Technische Festlegungen

- **Anmeldung:** Der eingebaute Rails-8-Authentifizierungsgenerator, ohne Passwort-Reset (es gibt keine Mails im MVP). Er benötigt `bcrypt`. `USER.role` ist ein Enum mit `traveler` (Standard) und `admin`.
- **Zeitzone:** `config.time_zone = "Zurich"`. Gespeichert wird in UTC, Anzeige und Eingabe erfolgen in Schweizer Zeit.
- **Routen:** `root` ist die Portalübersicht. Reservieren läuft über `POST /portals/:portal_id/bookings`, "Meine Reservierungen" über `/bookings`, der Admin-Bereich unter `/admin/portals` mit verschachtelten `bookings`. `Admin::BaseController` prüft die Rolle, alle übrigen Controller verlangen eine Anmeldung. Die Locking-Logik liegt im Modell (`Portal#reserve_seat_for(user)`), nicht im Controller.
- **Datenbank unter Last:** SQLite serialisiert Schreibzugriffe mit `BEGIN IMMEDIATE`. Wartet eine Transaktion länger als der Timeout (5000 ms), wird die Busy-Ausnahme abgefangen und als verständliche Meldung angezeigt ("Gerade ist viel los, versuch es gleich nochmal"). Es wird keine Reservierung gespeichert.
- **Live-Aktualisierung:** Turbo Streams über Action Cable. Drei Streams: `portals` (Portale und Reservierungen), `users`, `activities`. Modelle deklarieren ihren Stream mit `refreshes_pages_on`, Seiten hören mit `live_updates` zu. In der Entwicklung läuft der `async`-Adapter im selben Serverprozess, in Produktion `solid_cable`.
- **Protokoll:** Die Controller schreiben nach einer erfolgreichen Aktion einen Eintrag (`Activity.record`). Es gibt bewusst keine Model-Callbacks, damit klar bleibt, wer handelt.
- **Concurrency-Test:** Ein eigener Testfall ohne umschließende Test-Transaktion startet zehn Threads mit je eigener Datenbankverbindung, die den letzten Platz reservieren. Erwartet wird genau 1 Erfolg und 1 gespeicherte Reservierung.

### Abweichungen vom genehmigten Antrag

- Im ERM heissen die Spalten `USER.email_address` (statt `email`) und `USER.password_digest` (statt `password`). Grund: Der Rails-Authentifizierungsgenerator verwendet diese Namen, und ein Klartext-Passwort darf nicht gespeichert werden.
- Die Qualitätsattribute wurden überprüfbar formuliert (sechs allgemeine Aussagen wurden zu fünf messbaren zusammengeführt), weil die Wegleitung konkrete, überprüfbare Attribute verlangt.
- Der Abschnitt "Fat-Marker-Sketches: Transaktionen und Locking" heisst jetzt "Locking und Transaktionen" und beschreibt zusätzlich den Fall, dass Rick die Kapazität ändert.
- Ein Reisender, der eine Admin-Seite aufruft, wird auf die Startseite geleitet und sieht dort "Berechtigung fehlt." (statt einer eigenen Fehlerseite).
- Die mobile Ansicht ist kein Ziel. Die Applikation ist für den Desktop-Browser gebaut.
- Die Kapazitätsänderung läuft wie das Reservieren unter `Portal#with_lock`. Auf SQLite ist die explizite Sperre dort redundant, weil `save` eine eigene Schreibtransaktion um die Validierung öffnet (siehe `docs/adr/0002-capacity-enforced-with-portal-lock.md`).
