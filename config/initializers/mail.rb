raw_config = File.read(Rails.root.to_s + '/config/mail_config.yml')
MAIL_CONFIG = YAML.load(raw_config)[Rails.env].symbolize_keys

ActionMailer::Base.smtp_settings = {
  :tls => true,
  :address => 'smtp.gmail.com',
  :port => 587,
  :domain => $HOST,
  :authentication => :plain,
  :user_name => MAIL_CONFIG[:sender_email],
  :password => MAIL_CONFIG[:password]
}

ExceptionNotifier.exception_recipients = [MAIL_CONFIG[:webmaster_email]]
ExceptionNotifier.sender_address = %("TypeFront" <#{MAIL_CONFIG[:sender_email]}>)
