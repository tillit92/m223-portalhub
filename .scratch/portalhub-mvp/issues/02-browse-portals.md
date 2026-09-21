# 02: Portale ansehen

**What to build:** A logged-in Traveler sees the upcoming Portals and can open one for details. Each Portal shows name, Dimension, departure and "X von Y Plätzen frei", with the seats also drawn as a row of filled and free pips. A Full portal stays in the list marked "AUSGEBUCHT". Departed portals are hidden from the Traveler. The details page shows Capacity, booked and free seats and links back. Styled with the shared design from ticket 01.

**Blocked by:** 01 (Anmelden und Design-Grundlage)

**Status:** ready-for-agent

- [ ] A Portal has a name, a Dimension, a departure (date and time) and a Capacity
- [ ] A Booking (one User, one Portal) exists as data, with a database-level guarantee of at most one Booking per User and Portal; creating Bookings through the app comes in ticket 03
- [ ] Seeds add a handful of Portals with varying Capacity and some Bookings, including one Full portal and one Departed portal
- [ ] The overview is the home page after login, lists non-departed Portals with the soonest first, and shows "X von Y Plätzen frei" for each
- [ ] Rows are separated by dividers instead of three identical cards; the seat pips show real state (booked vs. free) and the free count is correct on every load
- [ ] A Full portal shows "AUSGEBUCHT"; a Departed portal does not appear for Travelers
- [ ] The details page shows name, Dimension, departure, Capacity, booked and free seats with the portal element and a link back
- [ ] Layout is readable at phone width with a single column
- [ ] Integration tests cover the list, ordering, hiding departed Portals, the Full portal display and the details page
