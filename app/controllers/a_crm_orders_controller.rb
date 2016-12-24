class ACrmOrdersController < ApplicationController
  def russian_post
    @order = ACrmOrder.find_by(num: params['num'])
    @history = @order.a_post_history.default
  end
end
