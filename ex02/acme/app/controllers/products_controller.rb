class ProductsController < ApplicationController
  before_action :authenticate_user!

  def index
    @products = Product.includes(:brand).order(:name)
  end

  def show
    @product = Product.find(params[:id])
  end
end
