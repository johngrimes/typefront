class LoggedRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :font

  def raw_request=(request_text)
    self.write_attribute(:raw_request, Base64.encode64(request_text)) unless request_text.blank?
  end

  def raw_request
    Base64.decode64(self.read_attribute(:raw_request)) unless self.read_attribute(:raw_request).blank?
  end
end
