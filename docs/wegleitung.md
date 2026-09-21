# Projektarbeit: Multiuser-Applikation

Dieses Dokument beschreibt die Anforderungen (Vorgaben) an die Projektarbeit im Modul.

- [Projekt definieren](#projekt-definieren)
- [Projektantrag vorlegen](#projektantrag-vorlegen)
- [Präsentation](#präsentation)
- [Abgabe](#abgabe)
- [Bewertungskriterien](#bewertungskriterien)

## Projekt definieren

In der Projektarbeit entwickeln Sie eine Multiuser-Applikation, welche am Ende des Moduls präsentiert und bewertet wird.

Bevor Sie mit der Projektarbeit beginnen, müssen Sie das Projekt beschreiben (den Rahmen definieren).
Dafür erstellen Sie eine Dokumentation (Projektantrag), welche als Grundlage für die Entwicklung der Applikation dient und für die weitere Dokumentation.

Durch die Beschreibung des Projektes soll es dem Kursleiter ermöglicht werden, Ziel und Umfang der Projektarbeit zu verstehen und beurteilen zu können.

### Problemstellung

- Beschreiben Sie eine Problemstellung (z.B. einen Prozess) aus Ihrem Alltag (beruflich oder privat), die mit einer Multiuser-Applikation automatisiert oder vereinfacht werden könnte.
- Erklären Sie, warum diese Problemstellung relevant ist und wie oft Sie damit konfrontiert werden.

### Projekt

- Domäne (Problembereich, Fachbereich)
- Name der Applikation
- Vision (Warum wird die Multiuser-Applikation entwickelt?)
- Projektplanung: 1. MVP Iteration (die wichtigste domänenspezifische
  funktionale Anforderung und alle dafür benötigten Multi-User Aspekte, die umgesetzt werden
  sollen, sind festzulegen!)

### Anforderungsanalyse

- Funktionale Anforderungen (mindestens sechs, priorisiert!)
- Qualitätsattribute als nicht-funktionale Anforderungen (mindestens vier, priorisiert und überprüfbar, jeweils konkret auf Ihre Domäne bezogen; z.B. Datenkonsistenz: Bei zwei gleichzeitigen Reservierungen des letzten freien Platzes wird genau eine bestätigt. Performance: Die Suche nach verfügbaren Kochkursen zeigt bei 1'000 erfassten Kursen und zehn gleichzeitigen Suchanfragen die Ergebnisse innerhalb von zwei Sekunden an. Allgemeine Aussagen wie «sicher» oder «benutzerfreundlich» reichen nicht aus.)
- Benutzerrollen (mindestens zwei mit unterschiedlichen Berechtigungen; weitere Rollen nur, wenn sie fachlich sinnvoll sind)
- Locking und Transaktionen: Beschreiben Sie, welche Funktionen diese benötigen und warum.
- ERM (Entity-Relationship-Model)
- Breadboards aller User-Flows der 1. Iteration
- Fat-Marker-Sketches (oder Wireframes) aller Screens der 1. Iteration

> Skizzen von Hand für ERM, Breadboards und Fat-Marker-Sketches sind
> ausreichend. Sie müssen nicht digital erstellt werden. Sie müssen aber lesbar
> und verständlich sein.

### Wichtige Hinweise

- Die Projektarbeit kann frei gestaltet werden
- Fokussieren Sie sich auf reale Problemstellungen aus Ihrem Alltag.
- Reine Nachbauten bekannter Applikationen (z.B. Jira, ein allgemeiner Chat oder eine Todo-App) sind nicht zugelassen. Entscheidend ist eine eigene, konkrete Problemstellung.
- Die Kernfunktion muss einen vollständigen fachlichen Ablauf abbilden, inklusive einer fachlichen Regel und eines Fehlerfalls. Anmeldung und reine Datenverwaltung reichen dafür nicht aus.
- Die Problemstellung sollte nicht-technisch sein (z.B. keine Datenimporte, Datenbankanbindungen oder Benutzerschnittstellen).
- Die Applikation muss von vielen Benutzern parallel genutzt werden können, wir sprechen von einer Multiuser-Applikation.
- Beschreiben Sie die Problemstellung aus der Sicht der Benutzer. Welche Bedürfnisse haben sie? Warum benötigen sie die Applikation?
- Eingesetzte Technologien müssen den im Unterricht besprochenen Vorgaben entsprechen.
- Die Dokumentationswerkzeuge können Sie frei wählen; Markdown-Quellen und PDF-Exporte sind wie unter Abgabe beschrieben einzureichen.

### Beispiel

[Projektarbeit Beispiel](/guides/projektarbeit/example.md)

## Projektantrag vorlegen

Legen Sie den initialen Projektantrag dem Kursleiter zur Beurteilung und Genehmigung vor.
**Beginnen Sie erst mit der Entwicklung, wenn der Projektauftrag vom Kursleiter genehmigt
wurde.**

Verfassen Sie den Projektantrag in Markdown und reichen Sie einen PDF-Export ein. Führen Sie ihn anschliessend als Projektdokumentation weiter.

## Präsentation

Am letzten Kurstag beginnen die Präsentationen direkt nach dem Wissenstest, ca. um 13:30 Uhr. Sie präsentieren Ihr Projekt dem Kursleiter und Ihrer Klasse.

Die Präsentation umfasst zwei Teile:

1. Planung und Konzeption Ihres Projektes (Vision, Domäne, Anforderungen, Modelle etc.). Erstellen Sie hierzu eine Folienpräsentation, welche die wichtigsten Informationen zu Ihrem Projekt im Überblick zeigt!
2. Live-Demo Ihrer Multi-User-Applikation (Multi-User-Funktionalität, Kernfunktionalität)

Die gesamte Präsentation dauert ca. 5 bis max. 10 Minuten.

## Abgabe

Auf Moodle!

Ablageort auf Moodle gemäss Unterricht als ZIP-Datei (`name-vorname.zip`) mit folgenden Dateien:

- Dokumentation als PDF-Export (`name-vorname_dokumentation.pdf`)
- Präsentation (`name-vorname_praesentation.pdf`)
- Source Code (`name-vorname_code.zip`), inklusive `README.md`, Tests und Markdown-Dokumentation unter `docs/` samt eingebundenen Bildern

## Bewertungskriterien

Die Bewertung der Projektarbeit ist im Kompetenznachweis ersichtlich. Die folgenden Vorgaben konkretisieren dessen Kriterien.

### Dokumentation

Die Dokumentation umfasst mindestens die aktuellen Inhalte des Projektantrages vom 2. Tag!

Legen Sie die Dokumentation im Markdown-Format im Verzeichnis `/docs` im Stammverzeichnis Ihres Source-Code-Projekts ab, inklusive aller eingebundenen Bilder.

Die Dokumentation erklärt das **Was und Warum**: Problemstellung, Vision, priorisierte Anforderungen und Qualitätsattribute, Rollen/Berechtigungen, ERM, Breadboards und Screens der ersten Iteration sowie das Konzept zu Locking und Transaktionen. Ergänzen Sie den erreichten Stand, begründete Abweichungen, offene Punkte sowie die Prüfung der Anforderungen und deren Ergebnisse. Halten Sie Modelle und Beschreibungen mit der Umsetzung aktuell.

Zusätzlich zum projektbezogenen Inhalt wird die Dokumentation nach folgenden
Kriterien bewertet:

- Das Layout kann frei gewählt werden, sollte jedoch durchgängig und übersichtlich sein.
- Das Titelblatt sollte folgende Angaben enthalten:
  - Modulname
  - Datum (TT.MM.JJJJ)
  - Vorname und Nachname des Autors
  - Schulklasse
- Sinnvolle, den Leser unterstützende Darstellung (z.B. Überschriften,
  Untertitel für Tabellen, Abbildungen, Code-Beispiele, etc.)
- Korrekte Rechtschreibung
- Einheitliche Verwendung von Fachbegriffen

### Applikation / Code

- `README.md` erklärt das **Wie des Ausführens**: Kurzbeschreibung, Technologie-Stack mit Versionen, Voraussetzungen, Installation/Konfiguration, Datenbankaufbau und Demo-Daten, Start- und Testbefehle sowie Demo-Konten mit Rollen. Verlinken Sie auf `docs/`, statt die Projektdokumentation zu wiederholen. Die Anleitung muss mit einer frischen Kopie funktionieren.
- Funktionalität (Applikation erfüllt die im KN geforderten und die in der 1.
  MVP Iteration definierten Anforderungen)
- Konventionen wurden eingehalten (Code Style, Namenskonventionen, etc.)
- Code Qualität (Lesbarkeit, Wartbarkeit, Effizienz)
- Automatisierte Tests prüfen die zentrale Fachregel sowie erlaubte und verweigerte Zugriffe. Alle Tests müssen bei der Abgabe erfolgreich laufen (siehe [Testing Cheatsheet](/guides/rails/testing-cheatsheet.md)).
- Fehlerbehandlung und User Feedback: Ungültige Eingaben, fehlende Berechtigungen und konkurrierende Änderungen werden serverseitig behandelt und verständlich erklärt. Eingaben bleiben soweit möglich erhalten; die nächste mögliche Handlung ist erkennbar. Erfolgreiche Aktionen werden bestätigt, technische Fehlermeldungen nicht ungefiltert angezeigt.

### Präsentation

- Präsentationsaufbau
- Aufmachung der Applikation
- Verständlichkeit
- Zeitmanagement
- Beantwortung von Fragen
