class Order < ApplicationRecord
  belongs_to :user, optional: true
  has_many :order_items, dependent: :destroy

  # Build (but don't save) an order from a cart, snapshotting each product's
  # current price so a later price change never rewrites past orders.
  def self.build_from_cart(cart, user: nil)
    order = new(user: user)
    cart.cart_items.includes(:product).each do |item|
      order.order_items.build(
        product: item.product,
        quantity: item.quantity,
        price: item.product.price
      )
    end
    order.total = order.order_items.sum(&:subtotal)
    order
  end
end
