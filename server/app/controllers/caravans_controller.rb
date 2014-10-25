$SUCCESS = 1

class CaravansController < ApplicationController
  
  # GET caravans/:caravan_id
  def show()
    id = params[:caravan_id]
    caravan = Caravan.get_caravan(id)
    if caravan.is_a? Integer
      render json: {reply_code: caravan}
      return
    end

    participant_ids = CaravanUser.where(caravan_id: id, accepted_invitation: true).map{|user| user.user_id}
    
    render json: {reply_code: $SUCCESS, caravan_id: id, 
      host_id: caravan.host_user_id, participants: participant_ids}
  end

end
