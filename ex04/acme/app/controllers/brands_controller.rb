class BrandsController < ApplicationController
  before_action :authenticate_user!

  def index
    @brands = Brand.order(:name)
  end

  def show
    @brand = Brand.find(params[:id])
  end
end
