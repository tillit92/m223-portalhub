# 12: Live-Aktualisierung

**What to build:** When one User reserves, cancels or an Admin changes something, every other open page that shows it updates by itself, without a reload. Rick sees Morty's reservation appear, and the free seats on everyone's overview change. Only a "look again" signal is sent, never HTML, so every browser fetches its own personal version of the page.

**Blocked by:** None (can start immediately)

**Status:** done

- [x] Reservations, cancellations and every change to Portals broadcast a refresh signal on a "portals" stream; changes to Users on "users"; new log entries on "activities"; refused actions send nothing
- [x] The overview, the details page, "Meine Reservierungen", the admin Portal table, the admin bookings of a Portal, the admin User table and the log listen on the right streams and refresh in place (morphing, scroll position kept)
- [x] Forms, the profile and the login page do not listen, so nobody loses what they are typing
- [x] Only a logged-in User can connect to the live channel
- [x] The User who acted does not have their own confirmation message wiped by the refresh
- [x] A real-browser check with two browsers proves a change shows up on the other without a reload
- [x] Integration tests cover the broadcasts, the pages that listen and the ones that do not, and the connection rules
