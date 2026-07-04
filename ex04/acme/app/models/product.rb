class Product < ApplicationRecord
  mount_uploader :pict, ImageUploader

  belongs_to :brand

  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
