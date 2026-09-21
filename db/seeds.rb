# Demo-Benutzer. Alle haben dasselbe Passwort.
demo_password = "wubba-lubba"

[
  { name: "Rick Sanchez", email_address: "rick@portalhub.test", role: :admin },
  { name: "Morty Smith", email_address: "morty@portalhub.test", role: :traveler },
  { name: "Summer Smith", email_address: "summer@portalhub.test", role: :traveler },
  { name: "Beth Smith", email_address: "beth@portalhub.test", role: :traveler },
  { name: "Birdperson", email_address: "birdperson@portalhub.test", role: :traveler }
].each do |attributes|
  user = User.find_or_initialize_by(email_address: attributes[:email_address])
  user.update!(attributes.merge(password: demo_password))
end
