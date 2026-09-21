# 01: Anmelden und Design-Grundlage

**What to build:** A User can log in with email and password, land on a first protected home page and log out. Rick (Admin) and a few Travelers exist from seed data with known demo passwords. Along the way the whole app gets its Rick and Morty look once, so every later ticket only reuses it: layout, navigation, flash messages, forms, buttons and the glowing portal element, following the "Design direction" in the spec. This is the walking skeleton.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] A User has a name, a login email, a password (stored hashed) and a role: Traveler (default) or Admin
- [ ] Seeds create Rick (Admin) and a few Travelers with documented demo passwords; the seed run works repeatedly and in the test environment
- [ ] Login with correct credentials lands on the home page; wrong credentials show a clear German message and keep the email filled in
- [ ] Logout ends the session; every page except login redirects a visitor who is not logged in to the login page
- [ ] No password reset and no self-registration
- [ ] Time zone is Swiss time for display and input, stored as UTC
- [ ] The design foundation from the spec's "Design direction" exists as shared styles and layout: dark theme, colors as variables, self-hosted fonts, one radius scale, one-line navigation, flash messages, form and button styles with hover/active/error states
- [ ] The login page is a split screen with the animated portal on one side and the form on the other; it works at phone width
- [ ] A short design read (one line) is stated before the styling work, as the design skill requires
- [ ] Integration tests cover login, wrong credentials, logout and the redirect for protected pages
