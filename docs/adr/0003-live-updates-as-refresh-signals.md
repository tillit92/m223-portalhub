# Live pages get a "look again" signal, not the new HTML

When one User changes something, the pages of other Users update by themselves. The server only broadcasts a refresh signal (Turbo Streams over Action Cable) on a stream per kind of data: `portals` for Portals and Bookings, `users`, `activities`. Every open page that shows such data then fetches itself again with its own session and morphs the differences in.

The alternative was to broadcast the changed HTML fragments. That was rejected because the pages are personal: Morty sees "Dein Platz ist reserviert", Rick sees admin tables, and the free seats, buttons and links differ by role. A pushed fragment would have to be rendered once per recipient, and a mistake there sends someone data that is not meant for them. A signal contains no data at all, so it cannot leak any, and the personalization stays where it already is, in the normal request.

## Consequences

- One small model concern (`LiveUpdates`) and one view helper (`live_updates`); a page becomes live by calling that helper, a model by declaring its stream.
- Each change costs one extra page request per open, listening page. With Turbo's debounce a burst of changes is merged into one refresh. For a classroom-sized app this is negligible.
- The browser that caused the change ignores the signal for its own request (Turbo attaches the request id), so its confirmation message is not wiped.
- Forms, the profile and the login page never listen, otherwise a refresh would wipe what someone is typing.
- Only a logged-in User can open the connection (`ApplicationCable::Connection` checks the signed session cookie). Because no data travels, a wrongly opened stream would leak nothing anyway.
- In development the `async` cable adapter works only inside one server process, which is how `bin/dev` runs. Production uses `solid_cable` (its own SQLite database), as already configured.
