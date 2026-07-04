class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def show
    @order = current_user.orders.find(params[:id])
  end

  # Checkout: turn the cart into an order, then clear the cart.
  def create
    cart = current_cart
    if cart.empty?
      redirect_to cart_path, alert: "Your cart is empty."
      return
    end

    order = Order.build_from_cart(cart, user: current_user)
    if order.save
      cart.destroy
      session.delete(:cart_id)
      redirect_to order_path(order), notice: "Order placed. Thank you!"
    else
      redirect_to cart_path, alert: "Could not place the order."
    end
  end
end
