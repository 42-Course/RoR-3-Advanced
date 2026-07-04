module CurrentCart
  extend ActiveSupport::Concern

  private

  # The cart for this browser session, created on demand. Keyed on the session
  # id so a returning visitor (same session cookie) gets their cart back, even
  # after closing the browser.
  def current_cart
    @current_cart ||= begin
      cart = Cart.find_by(id: session[:cart_id])
      cart ||= Cart.create!(session_id: session.id&.to_s)
      session[:cart_id] = cart.id
      cart
    end
  end
end
