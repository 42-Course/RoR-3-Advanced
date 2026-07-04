class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :orders, dependent: :nullify

  # name is mandatory; email/password are enforced by devise (:validatable).
  # bio is optional.
  validates :name, presence: true
end
