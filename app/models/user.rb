class User < ActiveRecord::Base
  has_many :zaglavljes
  has_many :kupacs
  has_many :import_logs

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
