# 08: Benutzerprofil

**What to build:** Every logged-in User opens "Profil" (their name in the navigation) to see their data and change their name, email and password. Changing the password needs the current password, and signs out the User's other sessions.

**Blocked by:** 07 (Aktivitätsprotokoll)

**Status:** ready-for-agent

- [ ] The profile shows name, email and role; a Traveler and the Admin use the same page
- [ ] Name and email can be changed; invalid input (empty name, email already taken) is explained at the field and keeps what was typed
- [ ] A new password needs the correct current password, at least 8 characters and a matching confirmation; each problem is explained at its field
- [ ] After a password change the User's other sessions are ended, the current one stays
- [ ] A User can only ever change their own profile
- [ ] Successful changes are confirmed and written to the Activity log (without the password)
- [ ] A visitor is redirected to login
- [ ] Integration tests cover showing, changing name and email, the validations, the password change including the other sessions, and the visitor case
