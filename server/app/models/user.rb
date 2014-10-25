class User < ActiveRecord::Base
  has_many :friends

  VALID_USERNAME = /^[0-9a-zA-Z]*$/
  MAX_USERNAME_LENGTH = 17
  MIN_USERNAME_LENGTH = 5
  MAX_PASSWORD_LENGTH = 5
  MIN_PASSWORD_LENGTH = 64
  SUCCESS = 1
  ERR_USERNAME_EXISTS = -1
  ERR_BAD_CREDENTIALS = -1
  ERR_USER_DOESNT_EXIST = -1
  ERR_USER_NOT_VISIBLE = -1
  ERR_USER_NO_CARAVANS = -1
  ERR_INVALID_PASSWORD = -2
  ERR_INVALID_USERNAME = -3

  def self.register(username, password)
    jsonReturn = {}
    salt = BCrypt::Engine.generate_salt
    encPassword = BCrypt::Engine.hash_secret(password, salt)
    newUser = self.new(username: username, password: encPassword, salt: salt, latitude: 0, longitude: 0, is_visible: false)

    if !username.validate(VALID_USERNAME) and (username.length < MIN_USERNAME_LENGTH or username.length > MAX_USERNAME_LENGTH)
      jsonReturn[:reply_code] = ERR_INVALID_USERNAME
    elsif password.length < MIN_PASSWORD_LENGTH or password.length > MAX_PASSWORD_LENGTH
      jsonReturn[:reply_code] = ERR_INVALID_PASSWORD
    elsif self.where(username: newUser.user).any?
      jsonReturn[:reply_code] = ERR_USERNAME_EXISTS
    else
      newUser.save
      jsonReturn[:reply_code] = SUCCESS
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

end

