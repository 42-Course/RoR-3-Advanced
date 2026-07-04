class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  # Add one unit of a product, creating the line if needed.
  # (The cart_items column defaults to 1, so a brand-new line already has
  # quantity 1 — only increment when the line already existed.)
  def add_product(product)
    item = cart_items.find_or_initialize_by(product: product)
    item.quantity = item.new_record? ? 1 : item.quantity + 1
    item.save
    item
  end

  def total
    cart_items.includes(:product).sum(&:subtotal)
  end

  def total_quantity
    cart_items.sum(:quantity)
  end

  def empty?
    cart_items.empty?
  end
end
