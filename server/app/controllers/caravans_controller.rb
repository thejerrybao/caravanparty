$SUCCESS = 1

class CaravansController < ApplicationController
  
  # GET caravans/:caravan_id
  def show
    id = params[:caravan_id]
    caravan = Caravan.get_caravan(id)
    if caravan.is_a? Integer    # error code
      render json: {reply_code: caravan}
      return
    end

    render json: {reply_code: $SUCCESS, caravan_id: id, 
      host_id: caravan.host_user_id, participants: Caravan.get_participants(id)}
  end

end
