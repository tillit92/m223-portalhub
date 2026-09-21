# PortalHub

A multiuser app where travelers reserve a seat on a portal to another dimension, in the world of Rick and Morty. Code and this glossary are English; the UI is German ("Reservierung", "Platz reservieren").

## Language

**Portal**:
One scheduled departure to a single dimension, with a limited number of seats. It is a one-off event (a date and time), not a recurring connection.
_Avoid_: Trip, flight, connection

**Dimension**:
The destination of a Portal, named like `C-137`. A plain attribute of the Portal, not an entity of its own.
_Avoid_: Destination, target

**Journey**:
Passing through a Portal at its departure. Only the act; it is never stored.
_Avoid_: Reise (as a name for the booking)

**Booking**:
One Traveler's claim on one seat of one Portal (UI: "Reservierung"). A Traveler holds at most one Booking per Portal. Cancelling deletes it and frees the seat immediately.
_Avoid_: Reservation, ticket, seat (as a model)

**Capacity**:
The maximum number of Bookings a Portal accepts. At least 1, and never lowered below the current number of Bookings.
_Avoid_: Size, limit, seats

**Free seats**:
Capacity minus the number of Bookings of a Portal. Always derived, never stored.
_Avoid_: Available seats, remaining

**Full portal**:
A Portal with no free seats. It stays visible ("AUSGEBUCHT") but cannot be booked.
_Avoid_: Sold out

**Departed portal**:
A Portal whose departure time has passed. It cannot be booked or cancelled, and is hidden from the Traveler's overview.
_Avoid_: Expired, past portal

## People

**User**:
Anyone who can log in. Users are created up front (seeds); there is no self-registration.
_Avoid_: Account, member

**Traveler**:
A User who browses Portals and books and cancels their own Bookings.
_Avoid_: Passenger, customer, Reisender

**Admin**:
A User (nickname "Rick") who creates, edits and deletes Portals and can view and cancel any Booking. An Admin can also book like a Traveler, but cannot book for others.
_Avoid_: Rick (as a role name in code), operator, superuser
