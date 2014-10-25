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

    # GET /users/:user_id
    def show
        user = User.getUser(params[:id])
        render json: user
    end

    # GET /users/:user_id/location
    def location
        userLocation = User.getUserLocation(params[:id])
        render json: userLocation
    end

    def caravans
        userCaravans = User.getUserCaravans(params[:id])
        render json: userCaravans
    end

end
