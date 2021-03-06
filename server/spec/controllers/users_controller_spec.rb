require "rails_helper"

SUCCESS = "SUCCESS"
ERR_USERNAME_EXISTS = "ERR_USERNAME_EXISTS"
ERR_BAD_CREDENTIALS = "ERR_BAD_CREDENTIALS"
ERR_USER_DOESNT_EXIST = "ERR_USER_DOESNT_EXIST"
ERR_USER_NOT_VISIBLE = "ERR_USER_NOT_VISIBLE"
ERR_USER_NO_CARAVANS = "ERR_USER_NO_CARAVANS"
ERR_INVALID_PASSWORD = "ERR_INVALID_PASSWORD"
ERR_INVALID_USERNAME = "ERR_INVALID_USERNAME"
ERR_USER_ALREADY_FRIENDS = "ERR_USER_ALREADY_FRIENDS"
ERR_USER_NOT_FRIENDS = "ERR_USER_NOT_FRIENDS"
ERR_USER_DOESNT_EXIST = "ERR_USER_DOESNT_EXIST"
ERR_USER_NO_REQUEST = "ERR_USER_NO_REQUEST"

describe UsersController do
  # describe "Users" do
  # end
  
  describe "Friends" do
    it "should be empty list for user with no friends" do
      u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
      
      get 'friends', :user_id => 333
      body = JSON.parse(response.body)
      expect(body['reply_code'] == SUCCESS).to eq true
      expect(body['friends'] == []).to eq true
    end

    it "should return empty lists of friends after only requests" do
      u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
      u2 = User.create(user_id: 334, username:'a', password:'bbbbbb')

      Friend.add(333, 334)
      
      get 'friends', :user_id => 333
      body = JSON.parse(response.body)
      expect(body['reply_code'] == SUCCESS).to eq true
      expect(body['friends'] == []).to eq true

      get 'friends', :user_id => 334
      body = JSON.parse(response.body)
      expect(body['reply_code'] == SUCCESS).to eq true
      expect(body['friends'] == []).to eq true
    end

    it "should return list of friend requests" do
      u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
      u2 = User.create(user_id: 334, username:'a', password:'bbbbbb')

      Friend.add(333, 334)
      
      get 'requests', :user_id => 333
      body = JSON.parse(response.body)
      expect(body['reply_code'] == SUCCESS).to eq true
      expect(body['requests'] == []).to eq true

      get 'requests', :user_id => 334
      body = JSON.parse(response.body)
      expect(body['reply_code'] == SUCCESS).to eq true
      expect(body['requests'] == [333]).to eq true
    end

    it "should add, accept friends properly" do
      u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
      u2 = User.create(user_id: 334, username:'a', password:'bbbbbb')

      post 'add', :user_id => 333, :other_user_id => 334
      body = JSON.parse(response.body)
      expect(body['reply_code'] == SUCCESS).to eq true
      
      post 'accept', :user_id => 334, :other_user_id => 333
      body = JSON.parse(response.body)
      expect(body['reply_code'] == SUCCESS).to eq true

      get 'friends', :user_id => 333
      body = JSON.parse(response.body)
      expect(body['reply_code'] == SUCCESS).to eq true
      expect(body['friends'] == [334]).to eq true

      get 'friends', :user_id => 334
      body = JSON.parse(response.body)
      expect(body['reply_code'] == SUCCESS).to eq true
      expect(body['friends'] == [333]).to eq true
    end

    it "should add, deny friends properly" do
      u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
      u2 = User.create(user_id: 334, username:'a', password:'bbbbbb')

      post 'add', :user_id => 333, :other_user_id => 334
      body = JSON.parse(response.body)
      expect(body['reply_code'] == SUCCESS).to eq true
      
      post 'deny', :user_id => 334, :other_user_id => 333
      body = JSON.parse(response.body)
      expect(body['reply_code'] == SUCCESS).to eq true

      get 'friends', :user_id => 333
      body = JSON.parse(response.body)
      expect(body['reply_code'] == SUCCESS).to eq true
      expect(body['friends'] == []).to eq true

      get 'friends', :user_id => 334
      body = JSON.parse(response.body)
      expect(body['reply_code'] == SUCCESS).to eq true
      expect(body['friends'] == []).to eq true
    end

    it "should error for accept/deny friends properly" do
      u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
      u2 = User.create(user_id: 334, username:'a', password:'bbbbbb')

      post 'add', :user_id => 333, :other_user_id => 334
      body = JSON.parse(response.body)
      expect(body['reply_code'] == SUCCESS).to eq true
      
      post 'deny', :user_id => 333, :other_user_id => 334
      body = JSON.parse(response.body)
      expect(body['reply_code'] == ERR_USER_NO_REQUEST).to eq true

      post 'accept', :user_id => 333, :other_user_id => 334
      body = JSON.parse(response.body)
      expect(body['reply_code'] == ERR_USER_NO_REQUEST).to eq true

      expect(Friend.all_friends(333) == []).to eq true
      expect(Friend.all_friends(334) == []).to eq true
      
      post 'accept', :user_id => 334, :other_user_id => 333
      body = JSON.parse(response.body)
      expect(body['reply_code'] == SUCCESS).to eq true

      # try correct accept/deny again but after they are already friends
      post 'deny', :user_id => 334, :other_user_id => 333
      body = JSON.parse(response.body)
      expect(body['reply_code'] == ERR_USER_ALREADY_FRIENDS).to eq true

      post 'accept', :user_id => 334, :other_user_id => 333
      body = JSON.parse(response.body)
      expect(body['reply_code'] == ERR_USER_ALREADY_FRIENDS).to eq true

      expect(Friend.all_friends(333).count == 1).to eq true
      expect(Friend.all_friends(334).count == 1).to eq true
    end

    it "should successfully delete friends properly" do
      u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
      u2 = User.create(user_id: 334, username:'a', password:'bbbbbb')

      Friend.add(333, 334)
      Friend.accept(334, 333)

      post 'delete', :user_id => 334, :other_user_id => 333
      body = JSON.parse(response.body)
      expect(body['reply_code'] == SUCCESS).to eq true

      expect(Friend.all_friends(333) == []).to eq true
      expect(Friend.all_friends(334) == []).to eq true
    end

    it "should error on delete friends properly" do
      u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
      u2 = User.create(user_id: 334, username:'a', password:'bbbbbb')

      post 'delete', :user_id => 334, :other_user_id => 333
      body = JSON.parse(response.body)
      expect(body['reply_code'] == ERR_USER_NOT_FRIENDS).to eq true

      post 'delete', :user_id => 334, :other_user_id => 335
      body = JSON.parse(response.body)
      expect(body['reply_code'] == ERR_USER_DOESNT_EXIST).to eq true
    end
    
  end
end
