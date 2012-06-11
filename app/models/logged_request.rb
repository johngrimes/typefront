class LoggedRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :font

  def user_agent=(user_agent_text)
    self.write_attribute(:user_agent, Base64.encode64(user_agent_text)) unless user_agent_text.blank?
  end

  def user_agent
    Base64.decode64(self.read_attribute(:user_agent)) unless self.read_attribute(:user_agent).blank?
  end
end
