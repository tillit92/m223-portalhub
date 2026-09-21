# 06: README, Doku-Abgleich und grünes bin/ci

**What to build:** The project is ready to hand in. The README explains how to run it from a fresh copy, the documentation matches what was built, and the full local CI passes.

**Blocked by:** 04 (Meine Reservierungen und Stornieren), 05 (Admin-Bereich für Rick)

**Status:** ready-for-agent

- [ ] The README covers a short description, the technology stack with versions, prerequisites, installation, database setup and demo data, start and test commands, and the demo accounts with their roles, and links to the docs instead of repeating them
- [ ] Following the README on a fresh copy gets the app running and the tests passing
- [ ] The docs reflect the implementation: ERM (including the renamed User columns), deviations from the approved proposal, and the quality-attribute checks with their results
- [ ] The two manual checks are run and recorded: load time of the overview with 100 Portals and ten parallel requests, and the main flows in current Chrome, Firefox and Safari
- [ ] Screenshots of the finished screens are added to the docs
- [ ] The glossary and ADRs still match the code
- [ ] The full local CI run passes: style, security audits and all tests including the seed run
