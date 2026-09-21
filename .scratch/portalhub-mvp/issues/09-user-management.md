# 09: Benutzerverwaltung

**What to build:** Rick manages the Users in the admin area: a table of all Users, and creating, editing and deleting them. Since there is no self-registration, this is how new Travelers and Admins come in. Rick cannot delete himself or change his own role, so there is always an Admin.

**Blocked by:** 07 (Aktivitätsprotokoll)

**Status:** done

- [x] The table lists name, email, role and number of Bookings, with Bearbeiten and Löschen, and a "+ Neuer Benutzer" button
- [x] Rick can create a User with name, email, role and a start password (at least 8 characters); invalid input is explained at the field and keeps what was typed
- [x] Rick can edit name, email and role, and optionally set a new password (left empty means unchanged)
- [x] Rick cannot change his own role and cannot delete himself, with a clear message
- [x] Deleting a User asks for confirmation naming the number of Bookings, then deletes the User, their Bookings and sessions; the seats are free again
- [x] Creating, changing and deleting a User are written to the Activity log
- [x] Every User admin page is refused for a Traveler and a visitor and changes no data
- [x] Integration tests cover create, edit, the validations, own-account rules, delete with the cascade and denied access for every entry point
