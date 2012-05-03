class User < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :email, :organization, :pwd_hash, :created_at, :updated_at
  
  validates :email, :presence => true;
  validates_uniqueness_of :email;
  
  validates :first_name, :presence => true;
  validates :last_name, :presence => true;
  validates :pwd_hash, :presence => true;
  
  validates :organization, :presence => true;
  
  has_many :workflows, :through => :permissions
  # validates_associated :permissions
  
  validates :created_at, :presence => true;
  validates :updated_at, :presence => true;
  
end
