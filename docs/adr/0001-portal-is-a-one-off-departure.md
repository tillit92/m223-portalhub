# A Portal is a one-off departure, not a recurring connection

`Portal.departure_time` is a full `datetime`. The wireframes show only times of day ("14:30"), which would suggest a daily connection, but that would force every Booking to carry a date and complicate the capacity rule. A connection that runs daily is modelled as several Portals. Recurring Portals are out of scope for the MVP.
