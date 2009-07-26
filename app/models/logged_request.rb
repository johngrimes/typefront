class LoggedRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :font
end
