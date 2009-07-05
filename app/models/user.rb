class User < ActiveRecord::Base
  has_and_belongs_to_many :fonts

  acts_as_authentic
end
