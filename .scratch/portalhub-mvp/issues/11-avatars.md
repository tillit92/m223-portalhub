# 11: Avatare (feste Auswahl)

**What to build:** Every User can pick a picture from a fixed set (Rick, Morty, Summer, Beth, Birdperson) or none, in the profile. Rick can assign one to any User. The picture shows next to the name in the navigation, the user table and the log; without one the initials show. No uploads.

**Blocked by:** 08 (Benutzerprofil), 09 (Benutzerverwaltung)

**Status:** done

- [x] `avatar` is empty or a key of the fixed set; anything else is refused with a message at the field; a blank value means none
- [x] The profile and the admin user form offer every avatar and "Keins", with the current one selected
- [x] The picture (or the initials) shows in the navigation, the user table and the activity log, also for someone who is gone
- [x] A change is written to the activity log
- [x] Seeds give the demo users their pictures
- [x] Every avatar in the set has an image file
- [x] Integration and model tests cover the above
