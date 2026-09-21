# Demo-Benutzer. Alle haben dasselbe Passwort.
demo_password = "wubba-lubba"

users = [
  { name: "Rick Sanchez", email_address: "rick@portalhub.test", role: :admin },
  { name: "Morty Smith", email_address: "morty@portalhub.test", role: :traveler },
  { name: "Summer Smith", email_address: "summer@portalhub.test", role: :traveler },
  { name: "Beth Smith", email_address: "beth@portalhub.test", role: :traveler },
  { name: "Birdperson", email_address: "birdperson@portalhub.test", role: :traveler }
].to_h do |attributes|
  user = User.find_or_initialize_by(email_address: attributes[:email_address])
  user.update!(attributes.merge(password: demo_password))
  [ user.email_address.split("@").first.to_sym, user ]
end

# Demo-Portale. Die Abflugzeiten sind relativ zu jetzt, damit immer
# kommende Portale, ein volles und ein bereits abgeflogenes zu sehen sind.
# Wer bucht, steht in `booked_by`.
today = Time.zone.today

[
  { name: "Morgen-Portal", dimension: "C-137", capacity: 5, departure_time: (today + 1).in_time_zone.change(hour: 14, min: 30),
    booked_by: %i[ morty summer beth ] },
  { name: "Abend-Portal", dimension: "J19-Zeta-7", capacity: 3, departure_time: (today + 1).in_time_zone.change(hour: 19),
    booked_by: %i[ morty summer birdperson ] },
  { name: "Nacht-Portal", dimension: "C-500", capacity: 6, departure_time: (today + 2).in_time_zone.change(hour: 23, min: 15),
    booked_by: %i[ beth ] },
  { name: "Cronenberg-Express", dimension: "Cronenberg-Welt", capacity: 4, departure_time: (today + 4).in_time_zone.change(hour: 8, min: 45),
    booked_by: [] },
  { name: "Gestern-Portal", dimension: "Gazorpazorp", capacity: 4, departure_time: (today - 1).in_time_zone.change(hour: 16),
    booked_by: %i[ morty ] }
].each do |attributes|
  booked_by = attributes.delete(:booked_by)
  portal = Portal.find_or_initialize_by(name: attributes[:name])
  portal.update!(attributes)

  portal.bookings.where.not(user: users.values_at(*booked_by)).destroy_all
  booked_by.each { |key| portal.bookings.find_or_create_by!(user: users.fetch(key)) }
end
