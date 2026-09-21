# Capacity is enforced by locking the Portal, not by a counter or validation alone

Bookings must never exceed a Portal's capacity, even when several Travelers book the last seat at once, and the same holds when an Admin lowers the capacity. Booking creation and capacity changes both run inside `Portal#with_lock`, and free seats are recounted inside that transaction. Free seats stay derived (capacity minus Bookings) rather than stored in a counter column.

On SQLite `lock!` emits no `FOR UPDATE`; serialization comes from the Rails 8 adapter starting every write transaction as `BEGIN IMMEDIATE`. That is why the check and the insert must share one transaction.

## Considered Options

- **Plain validation** (count, then insert): two requests can both see one free seat. Rejected, this is the exact race the project must prevent.
- **Counter column plus optimistic locking** (`lock_version`): needs retries and a second source of truth for free seats. Rejected as more moving parts for a single-writer SQLite database.
- **Unique index on seat numbers**: would need a Seat model, which the domain does not have.
