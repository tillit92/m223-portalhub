# 07: Aktivitätsprotokoll

**What to build:** Rick opens "Protokoll" in the admin area and sees who did what and when: logins (also failed ones), reservations and cancellations, and every change to Portals and Users. Entries stay readable after a User or Portal is deleted. Later tickets (08, 09) add their own entries.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] An Activity records the acting User (empty for a failed login), the User's name as it was at that moment, an action, a readable description and the time
- [ ] Entries are written for: login, failed login (with the email that was tried), logout, reservation, cancellation by the Traveler, cancellation by the Admin (naming both), Portal created, changed (naming the changed values) and deleted
- [ ] A refused action (full Portal, departed Portal, invalid input) writes no entry
- [ ] Deleting a User keeps their entries, with the name they had
- [ ] "Protokoll" in the admin area lists the newest entries first with time, who, action and description; it has an empty state
- [ ] Only the Admin can open it; a Traveler and a visitor are refused like on every admin page
- [ ] The admin area has a small navigation "Portale | Benutzer | Protokoll"
- [ ] Integration tests cover the entries for each action above, the empty state and denied access
