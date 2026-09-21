# Demo-Benutzer. Alle haben dasselbe Passwort.
demo_password = "wubba-lubba"

users = {
  rick: { name: "Rick Sanchez", email_address: "rick@portalhub.test", role: :admin, avatar: "rick" },
  morty: { name: "Morty Smith", email_address: "morty@portalhub.test", role: :traveler, avatar: "morty" },
  summer: { name: "Summer Smith", email_address: "summer@portalhub.test", role: :traveler, avatar: "summer" },
  beth: { name: "Beth Smith", email_address: "beth@portalhub.test", role: :traveler, avatar: "beth" },
  birdperson: { name: "Birdperson", email_address: "birdperson@portalhub.test", role: :traveler, avatar: "birdperson" }
}.transform_values do |attributes|
  user = User.find_or_initialize_by(email_address: attributes[:email_address])
  user.update!(attributes.merge(password: demo_password))
  user
end

# Demo-Portale. Die Abflugzeiten sind relativ zu heute, damit immer kommende
# Portale, ein volles und ein bereits abgeflogenes zu sehen sind.
# Wer gebucht hat, steht in `booked_by`.
departure = ->(days_from_today, hour, minute = 0) do
  (Time.zone.today + days_from_today).in_time_zone.change(hour: hour, min: minute)
end

[
  { name: "Morgen-Portal", dimension: "C-137", capacity: 5, departure_time: departure.(1, 14, 30),
    booked_by: %i[ morty summer beth ] },
  { name: "Abend-Portal", dimension: "J19-Zeta-7", capacity: 3, departure_time: departure.(1, 19),
    booked_by: %i[ morty summer birdperson ] },
  { name: "Nacht-Portal", dimension: "C-500", capacity: 6, departure_time: departure.(2, 23, 15),
    booked_by: %i[ beth ] },
  { name: "Cronenberg-Express", dimension: "Cronenberg-Welt", capacity: 4, departure_time: departure.(4, 8, 45),
    booked_by: [] },
  { name: "Gestern-Portal", dimension: "Gazorpazorp", capacity: 4, departure_time: departure.(-1, 16),
    booked_by: %i[ morty ] }
].each do |attributes|
  booked_by = attributes.delete(:booked_by)
  portal = Portal.find_or_initialize_by(name: attributes[:name])
  portal.update!(attributes)

  portal.bookings.where.not(user: users.values_at(*booked_by)).destroy_all
  booked_by.each { |key| portal.bookings.find_or_create_by!(user: users.fetch(key)) }
end
