class <%= user_class_name %> < ActiveRecord::Base

  # New columns need to be added here to be writable through mass assignment
  attr_accessible :username, :email, :password, :password_confirmation

  # Create virtual password attribute, and make sure that it gets hashed upon
  # the creation of a new user
  attr_accessor :password
<<<<<<< HEAD:rails_generators/nifty_authentication/templates/user.rb
  before_create :prepare_password

=======
  before_save :prepare_password
  
>>>>>>> e63ea6f70d9b932c262675e5afa03060fe07309b:rails_generators/nifty_authentication/templates/user.rb
  validates_presence_of :username

  # Email must be unique within system
  validates_uniqueness_of :username, :email, :allow_blank => true

  # Username can be composed of letters, numbers, and the following characters: . - _ @
  validates_format_of :username, :with => /^[-\w\._@]+$/i, :allow_blank => true, :message => "should only contain letters, numbers, or .-_@"

  # Email must look like an email address
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i

  validates_presence_of :password, :on => :create
  validates_confirmation_of :password

  # Password must be at least 4 characters
  validates_length_of :password, :minimum => 4, :allow_blank => true

  # Returns true or false depending on whther the supplied password matches the
  # one on the system for the specified login.
  # Login can be either username or email address.
  def self.authenticate(login, pass)
    <%= user_singular_name %> = find_by_username(login) || find_by_email(login)
    return <%= user_singular_name %> if <%= user_singular_name %> && <%= user_singular_name %>.matching_password?(pass)
  end

  # Checks a plain text password against the stored password hash.
  def matching_password?(pass)
    self.password_hash == encrypt_password(pass)
  end

  private

  # Generates a salt and hash for the plain text password for this user.
  def prepare_password
    unless password.blank?
      self.password_salt = Digest::SHA1.hexdigest([Time.now, rand].join)
      self.password_hash = encrypt_password(password)
    end
  end

  # Generates a SHA1 hash for the supplied plain text password.
  def encrypt_password(pass)
    Digest::SHA1.hexdigest([pass, password_salt].join)
  end
end
