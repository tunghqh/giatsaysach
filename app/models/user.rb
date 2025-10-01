class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # Removed :registerable to disable user registration
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
end
