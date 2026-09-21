# 05: Admin-Bereich für Rick

**What to build:** Rick manages everything in one admin area: a table of all Portals (departed ones included) where he can create, edit and delete Portals, and open the Bookings of a Portal to see who booked and cancel any Booking. Only Rick gets in; the "Admin" navigation link is shown to him only, and a Traveler who opens an admin URL sees "Berechtigung fehlt" with no data changed. The server enforces this, not just the hidden link. Same look as the rest of the app, with a plain table divided by rows.

**Blocked by:** 03 (Platz reservieren und Gleichzeitigkeit beweisen)

**Status:** done

- [x] The admin table lists all Portals with name, Dimension, departure, Capacity and booked seats, with actions Bearbeiten, Löschen and Reservierungen, and a "+ Neues Portal" button
- [x] All admin pages sit behind one shared role check: a Traveler sees "Berechtigung fehlt", a visitor goes to login, and no data changes
- [x] Rick can create and edit a Portal (name, Dimension, departure, Capacity) with Save and Cancel; invalid input keeps what was typed and says what to fix
- [x] A Capacity below 1 shows "Kapazität muss mind. 1 sein"; a Capacity below the current number of Bookings is refused with a message naming that number
- [x] Changing the Capacity uses the same Portal lock as reserving, so a concurrent reservation can never leave a Portal over Capacity
- [x] Deleting a Portal asks for confirmation naming "Es gibt X Reservierungen", then deletes the Portal and its Bookings
- [x] The Bookings view of a Portal shows who booked and lets Rick cancel any Booking after a confirmation; like for everyone, a Booking of a Departed portal cannot be cancelled
- [x] Rick can reserve for himself through the normal Traveler flow but has no way to reserve for anyone else
- [x] Successful actions are confirmed with a message
- [x] Integration tests cover create, edit, both Capacity validations, delete with the cascade, viewing and cancelling Bookings, and denied access for a Traveler and a visitor on every admin entry point
