class User < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :email, :organization, :pwd_hash, :salt, :created_at, :updated_at
  
  validates_presence_of :first_name, :last_name, :email, :organization, :pwd_hash, :salt
  
  validates_uniqueness_of :email
  
  MINIMUM_PASSWORD_LENGTH = 8
  validates :password, :length => {:minimum => MINIMUM_PASSWORD_LENGTH}, :on => :create
  
  has_many :workflows, :through => :permissions
  # validates_associated :permissions
  
  SHA512_REGEX = Regexp.new('[a-f0-9]{128}')
  SALT_LENGTH = 128
  SALT_BASE = 16 # If SALT_REGEX changes, then SALT_BASE must be updated accordingly.
  SALT_REGEX = Regexp.new("[a-f0-9]{#{SALT_LENGTH}}") # If SALT_BASE changes, then SALT_REGEX must be updated accordingly.
  
  validates_each :pwd_hash, :salt do |user, attribute, value|
    regex = case attribute
    when :pwd_hash
      SHA512_REGEX
    when :salt
      SALT_REGEX
    end
    if regex.match(value).nil?
      message = case attribute
                when :pwd_hash
                  "must match the regular expression #{SHA512_REGEX.inspect}"
                when :salt
                  "must match the regular expression #{SALT_REGEX.inspect}"
                end
      user.errors.add(attribute, message)
    end
  end
  
  def password=(plain_text_password)
    #if plain_text_password.length < MINIMUM_PASSWORD_LENGTH
    #  errors.add(:password, "is too short (minimum is #{MINIMUM_PASSWORD_LENGTH} characters)")
    #  return
    #end
    salt_as_array = Array.new(SALT_LENGTH) do
      rand(SALT_BASE).to_s(SALT_BASE)
    end
    self.salt = salt_as_array.join
    self.pwd_hash = hash_password(plain_text_password)
  end
  
  def password_valid?(candidate_password)
    candidate_hash = hash_password(candidate_password)
    return system('./bin/secure_str_cmp', pwd_hash, candidate_hash)
  end
  
  def hash_password(plain_text_password)
    salted_password = plain_text_password + salt
    return Digest::SHA512.hexdigest(salted_password)
  end
  
  def full_name
    return "#{first_name} #{last_name}"
  end
  
end
