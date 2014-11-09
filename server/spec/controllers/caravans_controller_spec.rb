require "rails_helper"

describe CaravansController do
  it "should be -1 for nonexistent caravan" do
    get 'show', :id => 3
    body = JSON.parse(response.body)
    expect(body['reply_code'] == -1).to eq true
  end

  it "should give nonexistent user error for create caravan" do
    post 'create', :user_id => 10
    body = JSON.parse(response.body)
    expect(body['reply_code'] == -2).to eq true
  end
  
  it "should have valid JSON response for creating caravans" do
    u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
    
    post 'create', :user_id => 333
    body = JSON.parse(response.body)
    expect(body['reply_code'] == 1).to eq true

    post 'create', :user_id => 333
    body = JSON.parse(response.body)
    expect(body['reply_code'] == -1).to eq true
  end

  it "should have valid JSON response for existing caravan" do
    u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
    c1 = Caravan.create_caravan(333)
    
    get 'show', :id => c1.caravan_id
    body = JSON.parse(response.body)
    expect(body['reply_code'] == 1).to eq true
    expect(body['id'] == c1.caravan_id).to eq true
    expect(body['host_id'] == c1.host_user_id).to eq true
  end

  it "should have valid JSON response for invites to caravan" do
    u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
    u2 = User.create(user_id: 334, username:'a', password:'bbbbbb')
    c1 = Caravan.create_caravan(333)

    post 'invite', :id => c1.caravan_id, :user_id => 334
    post 'deny', :id => c1.caravan_id, :user_id => 334
    body = JSON.parse(response.body)
    expect(body['reply_code'] == 1).to eq true
    
    post 'invite', :id => c1.caravan_id, :user_id => 334
    post 'accept', :id => c1.caravan_id, :user_id => 334
    
    get 'show', :id => c1.caravan_id
    body = JSON.parse(response.body)
    expect(body['reply_code'] == 1).to eq true
    expect(body['id'] == c1.caravan_id).to eq true
    expect(body['host_id'] == c1.host_user_id).to eq true
  end

  it "should have valid JSON response for invites errors to caravan" do
    u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
    c1 = Caravan.create_caravan(333)

    post 'invite', :id => c1.caravan_id, :user_id => 334
    
    body = JSON.parse(response.body)
    expect(body['reply_code'] == -2).to eq true

    u2 = User.create(user_id: 334, username:'a', password:'bbbbbb')
    post 'invite', :id => c1.caravan_id, :user_id => 334
    post 'invite', :id => c1.caravan_id, :user_id => 334

    body = JSON.parse(response.body)
    expect(body['reply_code'] == -1).to eq true
  end
  
  it "should have valid JSON response for accepts/deny errors to caravan" do
    u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
    u2 = User.create(user_id: 334, username:'a', password:'bbbbbb')
    c1 = Caravan.create_caravan(333)

    post 'deny', :id => c1.caravan_id, :user_id => 334
    body = JSON.parse(response.body)
    expect(body['reply_code'] == -1).to eq true

    post 'accept', :id => c1.caravan_id, :user_id => 334
    body = JSON.parse(response.body)
    expect(body['reply_code'] == -1).to eq true
  end

  it "should give nonexistent user error for other caravan operations" do
    u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
    c1 = Caravan.create_caravan(333)

    post 'deny', :id => c1.caravan_id, :user_id => 334
    body = JSON.parse(response.body)
    expect(body['reply_code'] == -2).to eq true

    post 'accept', :id => c1.caravan_id, :user_id => 334
    body = JSON.parse(response.body)
    expect(body['reply_code'] == -2).to eq true
  end

  it "should handle leaving users properly" do
    u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
    u2 = User.create(user_id: 334, username:'a', password:'bbbbbb')
    c1 = Caravan.create_caravan(333)
    Caravan.invite_user(c1.caravan_id, 334)
    Caravan.accept_invitation(c1.caravan_id, 334)

    post 'leave', :id => c1.caravan_id, :user_id => 333
    body = JSON.parse(response.body)
    expect(body['reply_code'] == -3).to eq true

    post 'leave', :id => c1.caravan_id, :user_id => 334
    body = JSON.parse(response.body)
    expect(body['reply_code'] == 1).to eq true
  end
    
end
