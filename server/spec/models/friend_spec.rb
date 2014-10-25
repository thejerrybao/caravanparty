require 'rails_helper'

$SUCCESS = 1
$ERR_USER_ALREADY_FRIENDS = -1
$ERR_USER_DOESNT_EXIST = -2
$ERR_USER_NO_REQUEST = -3

describe Friend do

  it "should not return friends before accepted" do
    u1 = User.create(user_id: 1, username:'a', password:'bbbbbb')
    u2 = User.create(user_id: 2, username:'b', password:'bbbbbb')
    f = Friend.add(1, 2)
    expect(Friend.all_friends(0).length).to eq 0
    expect(Friend.all_friends(1).length).to eq 0
    expect(Friend.all_friends(2).length).to eq 0

    expect(Friend.add(1, 2)).to eq $ERR_USER_ALREADY_FRIENDS
    expect(Friend.all_friends(0).length).to eq 0
    expect(Friend.all_friends(1).length).to eq 0
    expect(Friend.all_friends(2).length).to eq 0
  end

  it "should return friends after acceptance" do
    u1 = User.create(user_id: 1, username:'a', password:'bbbbbb')
    u2 = User.create(user_id: 2, username:'b', password:'bbbbbb')
    f = Friend.add(1, 2)
    expect(Friend.all_friends(1).length).to eq 0
    expect(Friend.all_friends(2).length).to eq 0

    expect(Friend.accept(1, 2)).to eq $ERR_USER_NO_REQUEST
    expect(Friend.all_friends(1).length).to eq 0
    expect(Friend.all_friends(2).length).to eq 0
    
    expect(Friend.accept(2, 1)).to eq $SUCCESS
    expect(Friend.all_friends(1).length).to eq 1
    expect(Friend.all_friends(2).length).to eq 1
  end

  it "should treat adding someone who requested you already as acceptance" do
    u1 = User.create(user_id: 1, username:'a', password:'bbbbbb')
    u2 = User.create(user_id: 2, username:'b', password:'bbbbbb')
    f = Friend.add(1, 2)
    
    expect(Friend.add(2, 1)).to eq $SUCCESS
    expect(Friend.all_friends(1).length).to eq 1
    expect(Friend.all_friends(2).length).to eq 1
  end
  
  it "should log requests correctly" do
    u1 = User.create(user_id: 1, username:'a', password:'bbbbbb')
    u2 = User.create(user_id: 2, username:'b', password:'bbbbbb')
    f = Friend.add(1, 2)

    expect(Friend.get_pending_requests(2).length).to eq 1
    expect(Friend.get_pending_requests(1).length).to eq 0

    Friend.accept(2, 1)
    expect(Friend.get_pending_requests(2).length).to eq 0
    expect(Friend.get_pending_requests(1).length).to eq 0
  end
    
  it "should fail for duplicate friend requests" do
    u1 = User.create(user_id: 1, username:'a', password:'bbbbbb')
    u2 = User.create(user_id: 2, username:'b', password:'bbbbbb')
    expect(Friend.add(1, 2)).to eq $SUCCESS
    expect(Friend.add(1, 2)).to eq $ERR_USER_ALREADY_FRIENDS
    Friend.accept(2, 1)
    expect(Friend.add(1, 2)).to eq $ERR_USER_ALREADY_FRIENDS
  end

  it "should succeed for repetitive adds/denies" do
    u1 = User.create(user_id: 1, username:'a', password:'bbbbbb')
    u2 = User.create(user_id: 2, username:'b', password:'bbbbbb')
    f = Friend.add(1, 2)
    expect(Friend.get_pending_requests(2).length).to eq 1
    expect(Friend.get_pending_requests(1).length).to eq 0

    expect(Friend.deny(1, 2)).to eq $ERR_USER_NO_REQUEST
    expect(Friend.deny(2, 1)).to eq $SUCCESS
    expect(Friend.get_pending_requests(2).length).to eq 0
    expect(Friend.get_pending_requests(1).length).to eq 0
    
    f = Friend.add(1, 2)
    expect(Friend.get_pending_requests(2).length).to eq 1
    expect(Friend.get_pending_requests(1).length).to eq 0

    expect(Friend.deny(1, 2)).to eq $ERR_USER_NO_REQUEST
    expect(Friend.deny(2, 1)).to eq $SUCCESS
    expect(Friend.get_pending_requests(2).length).to eq 0
    expect(Friend.get_pending_requests(1).length).to eq 0
  end

  it "should properly handle multiple removals and re-adds" do
    u1 = User.create(user_id: 1, username:'a', password:'bbbbbb')
    u2 = User.create(user_id: 2, username:'b', password:'bbbbbb')
    f = Friend.add(1, 2)
    Friend.accept(2, 1)

    expect(Friend.remove(1, 2)).to eq $SUCCESS
    expect(Friend.all_friends(1).length).to eq 0
    expect(Friend.all_friends(2).length).to eq 0

    expect(Friend.remove(1, 2)).to eq $SUCCESS # succeed anyway
    f = Friend.add(1, 2)
    Friend.accept(2, 1)
    expect(Friend.all_friends(1).length).to eq 1
    expect(Friend.all_friends(2).length).to eq 1
  end
end
