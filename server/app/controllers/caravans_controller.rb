$SUCCESS = "SUCCESS"

class CaravansController < ApplicationController
  
  # GET caravans/:id
  def show
    caravan = Caravan.get_caravan(params[:id])
    if caravan.is_a? String    # error code
      render json: {reply_code: caravan}
      return
    end

    render json: {
      reply_code: $SUCCESS,
      id: Integer(params[:id]), 
      host_id: caravan.host_user_id, 
      participants: Caravan.get_participants(params[:id]),
      destination: {latitude: caravan.dest_latitude,
        longitude: caravan.dest_longitude},
      is_active: caravan.is_active}
  end

  # POST caravans/create/:user_id
  def create
    caravan = Caravan.create_caravan(params[:user_id])
    if caravan.is_a? String    # error code
      render json: {reply_code: caravan}
      return
    end

    render json: {reply_code: $SUCCESS, id: caravan.id}
  end

  # POST caravans/:id/invite/:user_id
  def invite
    code = Caravan.invite_user(params[:id], params[:user_id])
    render json: {reply_code: code}
  end

  # POST caravans/:id/accept/:user_id
  def accept
    code = Caravan.accept_invitation(params[:id], params[:user_id])
    render json: {reply_code: code}
  end

  # POST caravans/:id/deny/:user_id
  def deny
    code = Caravan.deny_invitation(params[:id], params[:user_id])
    render json: {reply_code: code}
  end

  # POST caravans/:id/leave/:user_id
  def leave
    code = Caravan.remove_user(params[:id], params[:user_id])
    render json: {reply_code: code}
  end

  # POST caravans/:id/destination/:destination
  def set_destination
    code = Caravan.set_destination(params[:id], params[:destination])
    render json: {reply_code: code}
  end

end
