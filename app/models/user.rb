class User < ActiveRecord::Base
  attr_accessible :id, :first_name, :last_name, :email, :organization, :pwd_hash, :salt, :created_at, :updated_at
  
  validates_presence_of :first_name, :last_name, :email, :pwd_hash, :salt
  
  validates_uniqueness_of :email
  
  has_many :workflow_permissions
  has_many :workflows, :through => :workflow_permissions
  has_many :runs
  has_many :model_permissions, :dependent => :destroy
  has_many :models, :through => :model_permissions, :dependent => :destroy #TODO: we'd like the behavior to be that models are destroyed if the last user with permissions for the model is deleted.
  
  validates_associated :runs, :model_permissions
  
  SHA512_REGEX = Regexp.new('[a-f0-9]{128}')
  SALT_LENGTH = 128
  SALT_BASE = 16 # If SALT_BASE changes, then SALT_REGEX must be updated accordingly.
  SALT_REGEX = Regexp.new("[a-f0-9]{#{SALT_LENGTH}}") # If SALT_REGEX changes, then SALT_BASE must be updated accordingly.
  MINIMUM_PASSWORD_LENGTH = 8
  
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
    salt_as_array = Array.new(SALT_LENGTH) do
      rand(SALT_BASE).to_s(SALT_BASE)
    end
    self.salt = salt_as_array.join
    self.pwd_hash = hash_password(plain_text_password)
  end
  
  def password_valid?(candidate_password)
    candidate_hash = hash_password(candidate_password)
    return system(Rails.root.join('bin/secure_str_cmp').to_s, pwd_hash, candidate_hash)
  end
  
  def hash_password(plain_text_password)
    salted_password = plain_text_password + salt
    return Digest::SHA512.hexdigest(salted_password)
  end
  
  def full_name
    return "#{first_name} #{last_name}"
  end
  
end
