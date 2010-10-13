class MailJob
  @queue = :mail

  def self.perform(mailer_class, action, *args)
    eval("#{mailer_class}_mailer".camelize).send("deliver_#{action}", *args)
  end
end
