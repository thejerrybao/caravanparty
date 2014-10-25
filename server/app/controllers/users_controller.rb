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

<<<<<<< HEAD
  # GET /users/:id
=======
  # GET /users/:user_id
>>>>>>> cb2a54a1e6d8dd4afa9a8ac278b8073e016b968f
  def show
    user = User.getUser(params[:id])
    render json: user
  end

<<<<<<< HEAD
  # GET /users/:id/location
=======
  # GET /users/:user_id/location
>>>>>>> cb2a54a1e6d8dd4afa9a8ac278b8073e016b968f
  def location
    userLocation = User.getUserLocation(params[:id])
    render json: userLocation
  end

<<<<<<< HEAD
  # GET /users/:id/caravans
=======
  # GET /users/:user_id/caravans
>>>>>>> cb2a54a1e6d8dd4afa9a8ac278b8073e016b968f
  def caravans
    userCaravans = User.getUserCaravans(params[:id])
    render json: userCaravans
  end
<<<<<<< HEAD
=======

  # GET /users/:user_id/friends/requests
  def requests
    requests = Friend.get_pending_requests(params[:user_id])
    if requests.is_a? Integer
      render json: {reply_code: caravan}
      return
    end
>>>>>>> cb2a54a1e6d8dd4afa9a8ac278b8073e016b968f

    requests = requests.map{|friend| friend.user_id}
    render json: {reply_code: $SUCCESS, requests: requests}
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
    friends = friends.map{|f| f.user_id == Integer(params[:user_id]) ? f.other_user_id : f.user_id}
    render json: {reply_code: $SUCCESS, friends: friends}
  end
  
end
