class Domain < ActiveRecord::Base
  validates_presence_of :domain
  belongs_to :font

  attr_accessible :domain
end
