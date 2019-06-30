class EmailLogger
  def self.delivering_email(message)
    to = message.to
    subject = message.subject
    body = message.body

    user = User.find_by(email: to)
    user.messages << Message.new(subject: subject, body: body) if user.present?
  end
end
