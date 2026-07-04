class CartsController < ApplicationController
  before_action :authenticate_user!

  def show
    @cart = current_cart
  end

  # Cancel the cart: destroy it and its items, then start fresh.
  def destroy
    current_cart.destroy
    session.delete(:cart_id)
    redirect_to products_path, notice: "Your cart has been emptied."
  end
end
