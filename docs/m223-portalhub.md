# Projektarbeit – Rick and Morty PortalHub

PortalHub ist eine Multiuser-Webapplikation, die im Stil der Welt von Rick and Morty gestaltet ist.

Die Idee ist, dass Benutzer verschiedene Portale zu unterschiedlichen Dimensionen sehen und einen Platz für eine Reise durch ein Portal reservieren können.

Ein Portal hat eine bestimmte Anzahl an verfügbaren Plätzen. Wenn alle Plätze reserviert sind, kann kein weiterer Benutzer das Portal buchen.

Das Projekt wird mit Ruby on Rails und SQLite umgesetzt.


## Problemstellung

Rick und Morty reisen ständig durch verschiedene Dimensionen und benutzen dafür ihre Portal Gun. Wenn mehrere Personen mitreisen möchten, kann es schnell unübersichtlich werden, welches Portal wohin führt und wie viele Plätze noch frei sind.

**PortalHub** soll dieses Problem auf eine einfache Art lösen. Benutzer können verschiedene interdimensionale Portale ansehen und einen Platz für eine Reise reservieren.

Da mehrere Benutzer gleichzeitig ein Portal reservieren können, muss das System darauf achten, dass nicht mehr Personen ein Portal reservieren, als es Plätze gibt.

## Projekt

* **Domäne:** Interdimensionale Reisen und Portalreservierungen
* **Name der Applikation:** PortalHub
* **Vision:** PortalHub wird entwickelt, um Rick, Morty und anderen interdimensionalen Reisenden eine einfache Plattform zur Verfügung zu stellen, auf der sie Portale zu verschiedenen Dimensionen entdecken und einen Platz für ihre nächste Reise reservieren können.

## Projektplanung: 1. MVP Iteration

Die wichtigste funktionale Anforderung für die erste Iteration ist die **Reservierung eines Platzes für eine interdimensionale Reise**.

Benutzer können verfügbare Portale ansehen und Informationen wie die Ziel-Dimension, Abflugzeit und Anzahl der freien Plätze sehen. Anschliessend können sie einen Platz für die Reise reservieren.

Ein Portal besitzt eine maximale Kapazität. Wenn beispielsweise ein Portal maximal fünf Reisende aufnehmen kann, dürfen auch nicht mehr als fünf Personen gleichzeitig einen Platz reservieren.

Ein wichtiger Multiuser-Fall entsteht, wenn mehrere Reisende gleichzeitig versuchen, den letzten freien Platz zu reservieren. In diesem Fall darf nur eine Reservierung erfolgreich sein.

## Anforderungsanalyse

### Funktionale Anforderungen (priorisiert)


1.  Benutzer können sich anmelden.
2.	Benutzer können verfügbare Portale ansehen.
3.	Benutzer sehen die Anzahl der freien Plätze.
4.	Benutzer können einen Platz reservieren.
5.	Benutzer können ihre Reservierungen ansehen.
6.	Benutzer können ihre Reservierungen stornieren.
7.	Ein Administrator kann Portale erstellen, bearbeiten und löschen.
8.	Ein Portal darf seine maximale Kapazität nicht überschreiten.


### Qualitätsattribute

1. **Benutzerfreundlichkeit:** Die Portalreservierung soll einfach und übersichtlich durchgeführt werden können.
2. **Sicherheit:** Nur eingeloggte Benutzer dürfen Portalreisen reservieren.
3. **Berechtigungen:** Nur Rick/Admin darf Portale erstellen, bearbeiten und löschen.
4. **Zuverlässigkeit:** Die maximale Kapazität eines Portals darf auch bei mehreren gleichzeitigen Reservierungen nicht überschritten werden.
5. **Reaktionszeit:** Die wichtigsten Seiten sollen innerhalb von wenigen Sekunden geladen werden.
6. **Kompatibilität:** PortalHub soll mit gängigen Webbrowsern funktionieren.

### Benutzerrollen

1. **Interdimensionaler Reisender:** Kann Portale ansehen, freie Plätze prüfen, Reisen reservieren und eigene Reservierungen verwalten.
2. **Rick / Admin:** Kann Portale erstellen, bearbeiten und löschen sowie Reservierungen verwalten.

### ERM (Entity-Relationship-Model)

Das ERM besteht aus den drei wichtigsten Entitäten **Benutzer, Portal und Reservierung**.

Ein Benutzer kann mehrere Portalreisen reservieren. Eine Reservierung gehört jeweils zu einem Benutzer und einem Portal. Ein Portal kann mehrere Reservierungen haben.

![Diagramm vom ERM](/docs/diagrams/erm.svg "ERM")

**Beziehungen:**

* Benutzer → Reservierungen: 1:n
* Portal → Reservierungen: 1:n

### Breadboards

![Breadboard](/docs/diagrams/breadboard.svg "ERM")

### Fat-Marker-Sketches

![Fat Mark Sketch](/docs/diagrams/wireframes.svg "ERM")

## Transaktionen und Locking

Bei einer Portalreservierung muss sichergestellt werden, dass die maximale Anzahl an Reisenden nicht überschritten wird.

Wenn beispielsweise bei einem Portal nur noch ein Platz frei ist und zwei Reisende gleichzeitig versuchen, diesen Platz zu reservieren, darf nur eine Reservierung erfolgreich sein.

Durch eine geeignete Transaktion bzw. Sperrung wird verhindert, dass beide Benutzer den gleichen letzten Platz reservieren können.

## Beispiel für ein Portal

Ein Portal könnte beispielsweise so aussehen:

**Portal C-137**

* **Ziel:** Dimension C-137
* **Abflug:** 14:30 Uhr
* **Kapazität:** 5 Reisende
* **Bereits reserviert:** 3
* **Freie Plätze:** 2

Ein Benutzer kann anschliessend auf **„Portal reservieren“** klicken.

Wenn bereits alle fünf Plätze vergeben sind, wird beispielsweise folgende Meldung angezeigt:

> **🛸 Portal voll!**
> Dieses Portal hat bereits seine maximale Kapazität erreicht. Versuch es mit einer anderen Dimension, Morty!
