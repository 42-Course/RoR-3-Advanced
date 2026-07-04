class CartItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: [:increment, :decrement, :destroy]

  def create
    product = Product.find(params[:product_id])
    current_cart.add_product(product)
    redirect_back fallback_location: products_path, notice: "Added to cart."
  end

  def increment
    @item.increment_quantity
    redirect_to cart_path
  end

  def decrement
    @item.decrement_quantity
    redirect_to cart_path
  end

  def destroy
    @item.destroy
    redirect_to cart_path, notice: "Item removed."
  end

  private

  # Scope to the current cart so one session can't touch another's items.
  def set_item
    @item = current_cart.cart_items.find(params[:id])
  end
end
