$SUCCESS = 1

class CaravansController < ApplicationController
  
  # GET caravans/:id
  def show
    caravan = Caravan.get_caravan(params[:id])
    if caravan.is_a? Integer    # error code
      render json: {reply_code: caravan}
      return
    end

    render json: {reply_code: $SUCCESS, id: params[:id], host_id: 
      caravan.host_user_id, participants: Caravan.get_participants(params[:id])}
  end

end
