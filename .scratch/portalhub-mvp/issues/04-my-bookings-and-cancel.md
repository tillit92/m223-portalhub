# 04: Meine Reservierungen und Stornieren

**What to build:** A Traveler opens "Meine Reservierungen", sees their own Bookings and can cancel one after a confirmation question. Cancelling deletes the Booking and frees the seat immediately. Bookings for departed Portals stay visible but cannot be cancelled. A Traveler never sees or cancels another Traveler's Bookings.

**Blocked by:** 03 (Platz reservieren und Gleichzeitigkeit beweisen)

**Status:** ready-for-agent

- [ ] The page lists the current User's Bookings with Portal name, Dimension and departure, including those for Departed portals
- [ ] After a successful reservation the Traveler lands on this page with "Platz reserviert" and sees the new Booking (a refused reservation stays on the Portal page)
- [ ] The navigation links to "Portale" and "Meine Reservierungen"
- [ ] With no Bookings it shows a designed empty state with "Du hast noch keine Reservierung." and a link to the overview
- [ ] Cancelling asks for confirmation first, then deletes the Booking and confirms; the free count rises immediately
- [ ] Cancelling a Booking for a Departed portal is refused with a clear message and nothing changes
- [ ] Trying to cancel another User's Booking is refused and changes nothing; a visitor is redirected to login
- [ ] Styled with the shared design
- [ ] Integration tests cover listing, the empty state, cancelling, the departed restriction and the ownership check
