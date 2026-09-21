module UsersHelper
  ROLE_LABELS = { "traveler" => "Reisender", "admin" => "Admin" }.freeze

  def role_label(role)
    ROLE_LABELS.fetch(role.to_s)
  end

  def delete_user_prompt(user)
    delete_confirmation("Benutzer #{user.name}", user.bookings.size)
  end
end
