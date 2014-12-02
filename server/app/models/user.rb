class User < ActiveRecord::Base
  has_many :friends

  VALID_USERNAME = /^[0-9a-zA-Z]*$/
  MAX_USERNAME_LENGTH = 17
  MIN_USERNAME_LENGTH = 5
  MAX_PASSWORD_LENGTH = 64
  MIN_PASSWORD_LENGTH = 5
  SUCCESS = "SUCCESS"
  ERR_USERNAME_EXISTS = "ERR_USERNAME_EXISTS"
  ERR_BAD_CREDENTIALS = "ERR_BAD_CREDENTIALS"
  ERR_USER_DOESNT_EXIST = "ERR_USER_DOESNT_EXIST"
  ERR_USER_NOT_VISIBLE = "ERR_USER_NOT_VISIBLE"
  ERR_USER_NO_CARAVANS = "ERR_USER_NO_CARAVANS"
  ERR_INVALID_PASSWORD = "ERR_INVALID_PASSWORD"
  ERR_INVALID_USERNAME = "ERR_INVALID_USERNAME"
  ERR_USER_NO_CARAVAN_REQUESTS = "ERR_USER_NO_CARAVAN_REQUESTS"

  def self.register(username, password)
    jsonReturn = {}
    salt = BCrypt::Engine.generate_salt
    encPassword = BCrypt::Engine.hash_secret(password, salt)
    newUser = self.new(username: username, password: encPassword, salt: salt, latitude: 0, longitude: 0, is_visible: false)

    if !(username =~ VALID_USERNAME) or (username.length < MIN_USERNAME_LENGTH or username.length > MAX_USERNAME_LENGTH)
      jsonReturn[:reply_code] = ERR_INVALID_USERNAME
    elsif password.length < MIN_PASSWORD_LENGTH or password.length > MAX_PASSWORD_LENGTH
      jsonReturn[:reply_code] = ERR_INVALID_PASSWORD
    elsif self.where(username: newUser.username).any?
      jsonReturn[:reply_code] = ERR_USERNAME_EXISTS
    else
      newUser.save
      jsonReturn[:reply_code] = SUCCESS
      jsonReturn[:user_id] = newUser.user_id
      jsonReturn[:name] = username
    end

    return jsonReturn
  end

  def self.login(username, password)
    jsonReturn = {}
    user = self.find_by(username: username)
    if !user.blank?
      encPassword = BCrypt::Engine.hash_secret(password, user.salt)
      if encPassword == user.password
        jsonReturn[:reply_code] = SUCCESS
        jsonReturn[:user_id] = user.user_id
        jsonReturn[:name] = user.username

        friends1 = Friend.where(user_id: user.user_id)
        friends2 = Friend.where(other_user_id: user.user_id)
        jsonReturn[:friend_ids] = Array.new

        friends1.each do |friend|
          jsonReturn[:friend_ids].push(friend.other_user_id)
        end

        friends2.each do |friend|
          jsonReturn[:friend_ids].push(friend.user_id)
        end
      else
        jsonReturn[:reply_code] = ERR_BAD_CREDENTIALS
      end
    else
      jsonReturn[:reply_code] = ERR_BAD_CREDENTIALS
    end

    return jsonReturn
  end

  def self.getUser(user_id)
    jsonReturn = {}
    user = self.find_by(user_id: user_id)
    if !user.blank?
      jsonReturn[:reply_code] = SUCCESS
      jsonReturn[:user_id] = user.user_id
      jsonReturn[:name] = user.username
    else
      jsonReturn[:reply_code] = ERR_USER_DOESNT_EXIST
    end

    return jsonReturn
  end

  def self.getUserLocation(user_id)
    jsonReturn = {}
    user = self.find_by(user_id: user_id)
    if !user.blank?
      if user.is_visible
        jsonReturn[:reply_code] = SUCCESS
        jsonReturn[:user_id] = user.user_id
        jsonReturn[:name] = user.username
        jsonReturn[:latitude] = user.latitude
        jsonReturn[:longitude] = user.longitude
      else
        jsonReturn[:reply_code] = ERR_USER_NOT_VISIBLE
      end
    else
      jsonReturn[:reply_code] = ERR_USER_DOESNT_EXIST
    end

    return jsonReturn
  end

  def self.setUserLocation(user_id, latitude, longitude)
    jsonReturn = {}
    user = self.find_by(user_id: user_id)
    if !user.blank?
      user.latitude = latitude
      user.longitude = longitude
      user.save
      jsonReturn[:reply_code] = SUCCESS
    else
      jsonReturn[:reply_code] = ERR_USER_DOESNT_EXIST
    end

    return jsonReturn
  end

  def self.setUserVisibility(user_id, is_visible)
    jsonReturn = {}
    user = self.find_by(user_id: user_id)
    if !user.blank?
      user.is_visible = is_visible
      user.save
      jsonReturn[:reply_code] = SUCCESS
    else
      jsonReturn[:reply_code] = ERR_USER_DOESNT_EXIST
    end

    return jsonReturn
  end

  def self.getUserCaravans(user_id)
    jsonReturn = {}
    caravans = CaravanUser.where(user_id: user_id)
    if !caravans.blank?
      user = self.getUser(user_id)
      jsonReturn[:user_id] = user[:user_id]
      jsonReturn[:name] = user[:name]
      jsonReturn[:caravan_ids] = Array.new
      caravans.each do |caravan|
        jsonReturn[:caravan_ids].push(caravan.caravan_id)
      end
    else
      jsonReturn[:reply_code] = ERR_USER_NO_CARAVANS
    end

    return jsonReturn
  end

  def self.getUserCaravanRequests(user_id)
    jsonReturn = {}
    caravanRequests = CaravanUser.where(user_id: user_id, accepted_invitation: false, is_host: false)
    if caravanRequests.empty?
      jsonReturn[:reply_code] = ERR_USER_NO_CARAVAN_REQUESTS
    else
      jsonReturn[:reply_code] = SUCCESS
      jsonReturn[:caravan_ids] = Array.new
      caravanRequests.each do |caravanRequest|
        jsonReturn[:caravan_ids].push(caravanRequest.caravan_id)
      end
    end

    return jsonReturn
  end

end

