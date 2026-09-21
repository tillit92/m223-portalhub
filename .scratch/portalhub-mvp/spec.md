Status: ready-for-agent

# PortalHub MVP: reserving a seat on a Portal

## Problem Statement

Rick and Morty keep travelling through dimensions, and whenever more people want to come along it becomes unclear which Portal goes where and how many seats are still free. People double-book, overfill Portals, or simply don't know what is available. Several people also try to grab the last seat at the same time, and today nothing stops two of them from both believing they got it.

## Solution

PortalHub is a multiuser web app in the world of Rick and Morty. A Traveler logs in, sees the upcoming Portals with their Dimension, departure and free seats, opens a Portal and reserves a seat. They see and cancel their own Bookings. An Admin (Rick) creates, edits and deletes Portals and can view and cancel any Booking. A Portal never holds more Bookings than its Capacity, even when many Travelers book the last seat at the same moment: exactly one succeeds and the others are told the Portal is now full. The UI is German, in a Rick and Morty tone.

## User Stories

### Login and access

1. As a Traveler, I want to log in with my email and password, so that I can reserve seats under my own name.
2. As a Traveler, I want a clear message when my email or password is wrong, so that I know to try again instead of guessing what failed.
3. As a Traveler, I want my email to stay filled in after a failed login, so that I only retype the password.
4. As a visitor who is not logged in, I want to be sent to the login page when I open any protected page, so that I know I must log in first.
5. As a Traveler, I want to log out, so that nobody else can use my session on a shared computer.
6. As a Traveler, I want to land on the Portal overview after logging in, so that I can start reserving right away.
7. As the course instructor demoing the app, I want ready-made demo users with known passwords (Rick as Admin and several Travelers), so that I can try every role without registering.

### Browsing Portals

8. As a Traveler, I want to see a list of upcoming Portals with name, Dimension and departure, so that I can pick where I want to go.
9. As a Traveler, I want each Portal to show "X von Y Plätzen frei", so that I can see availability at a glance.
10. As a Traveler, I want the list ordered by departure with the soonest first, so that the next Portals are on top.
11. As a Traveler, I want Portals that already departed to be hidden from the list, so that I only see things I can still book.
12. As a Traveler, I want a Full portal to stay in the list marked "AUSGEBUCHT", so that I understand it exists but is taken.
13. As a Traveler, I want a details page for a Portal showing name, Dimension, departure, Capacity, booked seats and free seats, so that I can decide before reserving.
14. As a Traveler, I want a link back to the overview from the details page, so that I can compare other Portals.
15. As a Traveler, I want the details page to show the true free-seat count each time it loads, so that I am not misled by an outdated number after someone else has booked.

### Reserving a seat

16. As a Traveler, I want a "Platz reservieren" button on a Portal with free seats, so that I can reserve my seat in one step.
17. As a Traveler, I want a confirmation "Platz reserviert" and to see my new Booking afterwards, so that I know it worked.
18. As a Traveler, I want the free-seat count of the Portal to drop for everyone as soon as I reserve, so that the numbers stay truthful.
19. As a Traveler, I want the reserve button disabled and "0 Plätze frei" shown on a Full portal, so that I can't try a hopeless action.
20. As a Traveler, when I press reserve and the Portal has just filled up, I want the message "Portal voll! Dieses Portal hat bereits seine maximale Kapazität erreicht. Versuch es mit einer anderen Dimension, Morty!", so that I know why it failed and what to do next.
21. As a Traveler, I want no Booking to be saved when the Portal was full, so that I am never charged a seat I didn't get.
22. As a Traveler, I want to be stopped from reserving a second seat on the same Portal with "Du hast bereits einen Platz in diesem Portal.", so that I don't take two seats by accident.
23. As a Traveler, I want to be unable to reserve a Portal that has already departed, so that I never hold a seat on a journey that is gone.
24. As a Traveler, when the system is briefly overloaded, I want a friendly "Gerade ist viel los, versuch es gleich nochmal" instead of a technical error, so that I know to retry.
25. As a Traveler, I want reserving to require being logged in, so that every Booking belongs to a known User.

### My Bookings

26. As a Traveler, I want a "Meine Reservierungen" page listing my Bookings with Portal name, Dimension and departure, so that I can see where I am going.
27. As a Traveler, I want an empty state "Du hast noch keine Reservierung." when I have none, so that the page doesn't look broken.
28. As a Traveler, I want to cancel one of my Bookings, so that I can free the seat when my plans change.
29. As a Traveler, I want a confirmation question before a cancellation, so that I don't cancel by accident.
30. As a Traveler, I want the seat to be free again immediately after I cancel, so that another Traveler can take it.
31. As a Traveler, I want to be unable to cancel a Booking for a Portal that has already departed, so that history stays consistent.
32. As a Traveler, I want to never see or cancel another Traveler's Bookings, so that my data and theirs stay private.
33. As a Traveler, I want my Bookings for departed Portals to remain visible in my list, so that I can look back at where I have been.

### Admin: managing Portals

34. As an Admin, I want an admin area listing all Portals with name, Dimension, departure, Capacity and booked seats, so that I can manage them in one place.
35. As an Admin, I want departed Portals to stay visible in the admin area, so that I can still review them.
36. As an Admin, I want to create a Portal with name, Dimension, departure and Capacity, so that Travelers can book it.
37. As an Admin, I want a validation message "Kapazität muss mind. 1 sein" when I enter a Capacity below 1, so that I fix it.
38. As an Admin, I want my form input kept when validation fails, so that I don't retype everything.
39. As an Admin, I want to edit a Portal's name, Dimension, departure and Capacity, so that I can correct or adjust it.
40. As an Admin, I want to be prevented from lowering the Capacity below the current number of Bookings, with a message naming that number, so that I never strand existing Bookings.
41. As an Admin, I want a Capacity change and a concurrent reservation never to leave the Portal over Capacity, so that the rule holds even against my own edits.
42. As an Admin, I want to delete a Portal after a confirmation that tells me how many Bookings will be removed ("Es gibt X Reservierungen"), so that I know the consequence.
43. As an Admin, I want the Bookings of a deleted Portal to be removed with it, so that no orphaned Bookings remain.

### Admin: managing Bookings

44. As an Admin, I want to see per Portal who has a Booking, so that I know who is coming.
45. As an Admin, I want to cancel any Traveler's Booking, so that I can clear a seat when needed. Like everyone else, I cannot cancel a Booking for a Portal that has already departed.
46. As an Admin, I want to reserve a seat myself like a Traveler, so that I can join a journey too.
47. As an Admin, I do not want to reserve seats on behalf of others, so that every Booking reflects the Traveler's own choice.

### Permissions

48. As a Traveler, I want the "Admin" link hidden from my navigation, so that I only see what I can use.
49. As a Traveler who opens an admin URL directly, I want the message "Berechtigung fehlt" and no change to any data, so that permissions are enforced on the server and not just hidden.
50. As a visitor who is not logged in, I want to be unable to reserve or cancel anything, so that only authenticated Users change data.

### Multiuser correctness

51. As a Traveler, when nine other Travelers and I try to reserve the last seat at the same moment, I want exactly one of us to get it and the rest to see "Portal voll", so that the Portal is never overbooked.
52. As the course instructor, I want the concurrency rule to be proven by an automated test, so that I can trust the core requirement.

## Implementation Decisions

- **Domain model.** Three entities: User, Portal and Booking, with the vocabulary of `CONTEXT.md`. A Portal has a name, a Dimension, a departure (full date and time, a one-off event per ADR-0001) and a Capacity. A Booking links one User to one Portal. Free seats are derived (Capacity minus Bookings) and never stored.
- **User and roles.** A User has a name, a login email, a password and a role, either Traveler (default) or Admin. There is no self-registration; demo users come from seed data. The ERM names the login column `email_address` and stores a password digest instead of a plain password.
- **Authentication.** The framework's built-in authentication is used, without password reset (no mail in the MVP). This needs the password-hashing gem enabled. Every controller requires login except the login page itself.
- **Authorization.** A separate admin area sits behind a base controller that checks the Admin role and otherwise shows "Berechtigung fehlt". Traveler-facing controllers only ever act on the current User's own Bookings. The Admin navigation link is shown to Admins only, and the server check is what actually enforces access.
- **Routes and controllers.** Root is the Portal overview. Reserving is a create action nested under a Portal. "Meine Reservierungen" is the Bookings index with a destroy action. The admin area has Portals CRUD, with a nested Bookings index and destroy for managing Bookings per Portal.
- **Reserving a seat: single deep module.** A Portal exposes one operation to reserve a seat for a User. It takes the Portal lock (ADR-0002), recounts free seats inside the transaction, rejects a departed Portal, rejects a second Booking by the same User on the same Portal, and otherwise creates the Booking. It reports success or a specific reason (full, already booked, departed). The controller only translates that result into a message and redirect.
- **Changing Capacity.** Updating a Portal's Capacity takes the same Portal lock and validates Capacity is at least 1 and not below the current number of Bookings. This keeps a single locking concept for both writers (ADR-0002).
- **Cancelling.** A Booking is deleted outright, which frees the seat immediately. Cancelling is refused once the Portal has departed. There is no status column and no history.
- **Deleting a Portal.** Deleting a Portal deletes its Bookings with it, after a confirmation naming how many will go.
- **Schema.** A unique constraint on the pair of User and Portal in Bookings backs the "one seat per Traveler per Portal" rule at the database level. Foreign keys back both references. Capacity is validated at least 1.
- **Visibility of departed Portals.** The Traveler overview excludes Portals whose departure has passed. The Admin area and a Traveler's own Bookings list still show them.
- **Time zone.** The app runs in Swiss time (Zurich) for display and input, and stores UTC. "Departed" is decided against the current time in that zone.
- **Load and lock errors.** SQLite serializes writers with immediate write transactions. A busy timeout during reserving is caught and shown as "Gerade ist viel los, versuch es gleich nochmal", with no Booking saved. The technical error is never shown to the user.
- **Feedback.** Successful actions are confirmed with a flash message. Failures explain the reason and the next possible step. Form input is preserved on validation errors.
- **UI language and tone.** All user-facing text is German with a light Rick and Morty tone. Code and glossary stay English.
- **Keep it simple.** This is a school project. Prefer the plain Rails way (server-rendered pages, standard forms, built-in features) over clever abstractions, and add nothing the stories do not ask for.
- **Seed data.** Seeds create Rick (Admin), a few Travelers and a handful of Portals with varying Capacity, including one Full portal and one departed Portal, so every state can be demonstrated. Names follow the Rick and Morty world (see Design direction).

## Design direction

Every screen, the admin area included, follows the `design-taste-frontend` skill, adapted to this stack: plain CSS with the existing asset pipeline, no Tailwind, no React and no JavaScript animation library, because the app has no build step. The design is set up once in ticket 01 and reused everywhere.

- **Design read:** a dark sci-fi interface in the style of Rick and Morty, playful but readable. Dials: VARIANCE 7, MOTION 4, DENSITY 4.
- **Theme lock:** dark on every page. Off-black with a slight green tint instead of pure black, off-white text instead of pure white. Colors are defined once as variables.
- **One accent:** portal green, used consistently for actions, focus and the portal element. Glow (shadows and blurs) is allowed only on the portal element, including its small logo mark, and on focus, because the theme asks for it. A faint green tint in page backgrounds is fine. Buttons do not glow. No second accent, no purple gradients.
- **Type:** a geometric sans for text and headings and a matching monospace for numbers and small labels (Geist and Geist Mono), self-hosted with a swap fallback. No Inter, no serif.
- **Signature element:** a swirling green portal built from CSS gradients and a slow rotation, on the login page and the Portal details page. It stands still when the user prefers reduced motion. No hand-drawn SVG illustrations.
- **Layout:** the login page is an asymmetric split screen (portal on one side, form on the other). The Portal list uses dividers, not rows of identical cards. Seats are shown as a row of pips that show real state (booked vs. free), next to the "X von Y Plätzen frei" text. The admin table uses row dividers, no cards. One-line navigation.
- **Shape and feel:** one radius scale for the whole app. Buttons and links have hover, active (small press) and focus states. Motion is CSS only and short.
- **States and forms:** designed empty, error, success and disabled states. Labels sit above inputs, errors below, never placeholder-as-label.
- **Accessibility:** WCAG AA contrast for text, buttons, inputs and messages; motion respects reduced-motion preferences.
- **Responsive:** single column below tablet width, navigation stays on one line or collapses cleanly, no horizontal scrolling.
- **Copy:** German, short, with a light Rick and Morty tone. No em-dashes (use a plain hyphen), no marketing filler words, no fake-perfect demo numbers, and creative Rick and Morty style names for demo Users and Portals instead of "Test User".

## Testing Decisions

- **What makes a good test.** Tests exercise external behaviour through the same entry points a user has: requests and their visible results (redirects, messages, what the pages show, what is stored). They do not assert on private methods, query counts or internal structure, so refactoring the reservation logic does not break them.
- **Seam 1: HTTP integration tests (primary).** Cover login and logout, redirect to login for protected pages, browsing and hiding departed Portals, reserving with success, Full portal, duplicate Booking and departed Portal, cancelling with confirmation flow and the departed restriction, seeing only my own Bookings, admin Portal CRUD including the Capacity-below-Bookings and Capacity-below-1 validations, deleting a Portal with Bookings, and admin viewing and cancelling Bookings. Permission tests cover both allowed and denied access: a Traveler and a visitor against every admin and protected endpoint must be refused with no data change ("Berechtigung fehlt" or redirect to login).
- **Seam 2: concurrency test on the reserve operation (exception).** A dedicated test outside the wrapping test transaction starts ten threads, each with its own database connection, all reserving the last free seat. It expects exactly one success, nine "full" results and exactly one stored Booking. It cleans up after itself and does not run inside the parallelized fixture environment. This seam exists only because true parallelism cannot be reliably produced through HTTP integration tests.
- **Time.** Tests freeze the clock to decide "departed" and to show the Swiss-time display.
- **Prior art.** None yet: the repository holds only the generated test helper with fixtures and parallel workers. Use fixtures for Users (Admin and Traveler), Portals (open, full, departed) and Bookings, following the conventions once they are written down.
- **Out of the test suite.** Load time (Portal overview with 100 Portals and ten parallel requests) and browser compatibility are verified manually or with a one-off load test, as stated in the quality attributes, not in the regular suite.

## Out of Scope

- Self-registration, password reset, email verification and any outgoing mail or notifications.
- Recurring Portals and reserving several seats in one Booking or for other people.
- Booking history or cancelled-Booking records, waiting lists, and payments.
- Search, filtering and paging of Portals beyond the departure-ordered list.
- Live updating of free seats via push (the count is correct on each page load).
- More than the two roles, and an Admin booking on behalf of a Traveler.
- Browser-driven system tests.
- A JavaScript build step, Tailwind, React or an animation library.
- Light mode and a theme toggle: the app is dark only.

## Further Notes

- The binding sources are `docs/spec.md` (requirements and the section "Präzisierungen und Abweichungen nach der Genehmigung"), `CONTEXT.md` (vocabulary), and ADR-0001 and ADR-0002 in `docs/adr/`. If this spec and `docs/spec.md` disagree, `docs/spec.md` wins and this spec should be corrected.
- `docs/conventions.md` is referenced from `CLAUDE.md` but does not exist yet; follow it once it is added.
- The module grades tests for the core rule and for allowed and denied access, plus README and documentation that stay in sync with the implementation. Keep the README's demo accounts, seed data and test commands current as features land.
