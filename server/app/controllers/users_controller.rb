$SUCCESS = 1
class UsersController < ApplicationController

  # POST /register
  def register
    newUser = User.register(params[:username], params[:password])
    render json: newUser
  end

  # POST /login
  def login
    login = User.login(params[:username], params[:password])
    render json: login
  end

  # GET /users/:id
  def show
    user = User.getUser(params[:id])
    render json: user
  end

  # GET /users/:id/location
  def location
    userLocation = User.getUserLocation(params[:id])
    render json: userLocation
  end

  # POST /users/:id/location
  def updatelocation
    updateUserLocation = User.setUserLocation(params[:id], params[:latitude], params[:longitude])
    render json: updateUserLocation
  end

  # POST /users/:id/location/visibility
  def updateuservisibility
    updateUserVisibility = User.setUserVisibility(params[:id], params[:is_visible])
    render json: updateUserVisibility
  end

  # GET /users/:id/caravans
  def caravans
    userCaravans = User.getUserCaravans(params[:id])
    render json: userCaravans
  end

  # GET /users/:user_id/friends/requests
  def requests
    requests = Friend.get_pending_requests(params[:user_id])
    if requests.is_a? Integer
      render json: {reply_code: caravan}
      return
    end

    requests = requests.map{|friend| friend.user_id}
    render json: {reply_code: $SUCCESS, requests: requests}
  end

  # POST /users/:user_id/friends/add/:other_user_id
  def add
    code = Friend.add(params[:user_id], params[:other_user_id])
    render json: {reply_code: code}
  end

  # POST /users/:user_id/friends/delete/:other_user_id
  def delete
    code = Friend.remove(params[:user_id], params[:other_user_id])
    render json: {reply_code: code}
  end

  # GET /users/:user_id/friends/accept/:other_user_id
  def accept
    code = Friend.accept(params[:user_id], params[:other_user_id])
    render json: {reply_code: code}
  end

  # GET /users/:user_id/friends/deny/:other_user_id
  def deny
    code = Friend.deny(params[:user_id], params[:other_user_id])
    render json: {reply_code: code}
  end

  # GET /users/:user_id/friends
  def friends
    friends = Friend.all_friends(params[:user_id])
    # other_user_id might be in f.user_id or f.other_user_id, pick the right one
    friends = friends.map{|f| f.user_id == Integer(params[:user_id]) ? f.other_user_id : f.user_id}
    render json: {reply_code: $SUCCESS, friends: friends}
  end
  
end
