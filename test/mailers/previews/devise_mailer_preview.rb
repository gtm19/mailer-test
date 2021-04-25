
class DeviseMailerPreview < ActionMailer::Preview

  USER = User.new(email: "hello@test.com")

  def confirmation_instructions
    Devise::Mailer.confirmation_instructions(USER, {})
  end

  def unlock_instructions
    Devise::Mailer.unlock_instructions(USER, "faketoken")
  end

  def reset_password_instructions
    Devise::Mailer.reset_password_instructions(USER, "faketoken")
  end
end
