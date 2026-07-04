class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }

  def subtotal
    quantity * (product.price || 0)
  end

  def increment_quantity
    increment!(:quantity)
  end

  # Decreasing below one removes the line entirely.
  def decrement_quantity
    if quantity > 1
      decrement!(:quantity)
    else
      destroy
    end
  end
end
