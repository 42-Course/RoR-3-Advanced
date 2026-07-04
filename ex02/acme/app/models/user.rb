class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # name is mandatory; email/password are enforced by devise (:validatable).
  # bio is optional.
  validates :name, presence: true
end
