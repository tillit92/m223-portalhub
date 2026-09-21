module UsersHelper
  ROLE_LABELS = { "traveler" => "Reisender", "admin" => "Admin" }.freeze

  def role_label(role)
    ROLE_LABELS.fetch(role.to_s)
  end

  def delete_user_prompt(user)
    delete_confirmation("Benutzer #{user.name}", user.bookings.size)
  end

  # The picture of a User, or their initials in a circle when they have none.
  # Decorative: the name is always written next to it, so the alt text is empty.
  def avatar_tag(user, size: :small, name: nil)
    if user&.avatar
      image_tag "#{user.avatar}.png", alt: "", class: "avatar avatar--#{size}"
    else
      tag.span(class: "avatar avatar--#{size} avatar--initials", data: { initials: initials(user&.name || name) }, aria: { hidden: true })
    end
  end

  def initials(name)
    name.to_s.split.first(2).map { |word| word[0] }.join.upcase.presence || "?"
  end
end
