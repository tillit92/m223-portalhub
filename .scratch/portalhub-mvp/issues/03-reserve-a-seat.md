# 03: Platz reservieren und Gleichzeitigkeit beweisen

**What to build:** A logged-in Traveler reserves a seat from a Portal's details page. On success they see "Platz reserviert" and the free count drops for everyone. Reserving is refused with a specific German message and nothing saved when the Portal is full, when the Traveler already holds a seat on it, or when it has departed. The core requirement is proven by an automated test: with ten Travelers trying for the last seat at once, exactly one wins (ADR-0002).

**Blocked by:** 02 (Portale ansehen)

**Status:** done

- [x] Reserving takes the Portal lock, recounts free seats inside the transaction and creates the Booking only if a seat is free
- [x] Success shows "Platz reserviert" and the seat pips and free count update for everyone
- [x] A Full portal shows 0 free seats and a disabled reserve button; a forced attempt shows "Portal voll! Dieses Portal hat bereits seine maximale Kapazität erreicht. Versuch es mit einer anderen Dimension, Morty!" and saves nothing
- [x] A second Booking on the same Portal is refused with "Du hast bereits einen Platz in diesem Portal."; a Departed portal cannot be reserved; a visitor cannot reserve
- [x] A database busy timeout while reserving is caught and shown as "Gerade ist viel los, versuch es gleich nochmal" with nothing saved
- [x] The reserve logic lives in the model behind one operation that reports success or the reason; the controller only turns that into a message
- [x] A dedicated test outside the wrapping test transaction starts ten threads with their own database connections and asserts exactly one success and exactly one stored Booking; it cleans up after itself
- [x] Integration tests cover success, full, duplicate, departed and unauthenticated attempts
- [x] The buttons and messages use the shared design, including the disabled and error states
