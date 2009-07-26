class LoggedRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :font
  serialize :request_info
end
