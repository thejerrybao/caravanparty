require 'rails_helper'

$SUCCESS = "SUCCESS"
$ERR_USER_NOT_IN_CARAVAN = "ERR_USER_NOT_IN_CARAVAN"
$ERR_USER_ALREADY_INVITED = "ERR_USER_ALREADY_INVITED"
$ERR_USER_ALREADY_HOSTING = "ERR_USER_ALREADY_HOSTING"
$ERR_CARAVAN_DOESNT_EXIST = "ERR_CARAVAN_DOESNT_EXIST"
$ERR_NO_EXISTING_INVITATION = "ERR_NO_EXISTING_INVITATION"
$ERR_USER_DOESNT_EXIST = "ERR_USER_DOESNT_EXIST"
$ERR_HOST_CANNOT_BE_REMOVED = "ERR_HOST_CANNOT_BE_REMOVED"

describe Caravan do
  
  it "should fail when creating caravan with nonexistent user" do
    expect(Caravan.create_caravan(333)).to eq $ERR_USER_DOESNT_EXIST

    u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
    u1.destroy
    expect(Caravan.create_caravan(333)).to eq $ERR_USER_DOESNT_EXIST
  end

  it "should succeed on basic creation of caravan" do
    u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
    c1 = Caravan.create_caravan(333)
    expect(c1.is_a? Integer).to eq false
  end

  it "should fail when creating caravan with user that is already hosting" do
    u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
    expect(Caravan.create_caravan(333).is_a? Integer).to eq false
    expect(Caravan.create_caravan(333)).to eq $ERR_USER_ALREADY_HOSTING
  end

  it "should succeed when creating caravan with user that is not hosting but in another caravan" do
    u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
    u2 = User.create(user_id: 334, username:'a', password:'bbbbbb')
    expect(Caravan.create_caravan(333).is_a? Integer).to eq false
    expect(Caravan.create_caravan(333)).to eq $ERR_USER_ALREADY_HOSTING
    expect(Caravan.create_caravan(334).is_a? Integer).to eq false
  end

  it "should return 1 for get_participants of newly created Caravan" do
    u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
    c1 = Caravan.create_caravan(333)
    expect(Caravan.get_participants(c1.caravan_id).count).to eq 1
  end

  it "should accept caravan invitations properly" do
    u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
    u2 = User.create(user_id: 334, username:'a', password:'bbbbbb')
    c1 = Caravan.create_caravan(333)
    expect(Caravan.get_participants(c1.caravan_id).count).to eq 1
    
    expect(Caravan.invite_user(c1.caravan_id, 334)).to eq $SUCCESS
    expect(Caravan.accept_invitation(c1.caravan_id, 334)).to eq $SUCCESS

    expect(Caravan.get_participants(c1.caravan_id).count).to eq 2
  end

  it "should deny caravan invitations properly" do
    u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
    u2 = User.create(user_id: 334, username:'a', password:'bbbbbb')
    c1 = Caravan.create_caravan(333)
    
    expect(Caravan.invite_user(c1.caravan_id, 334)).to eq $SUCCESS
    expect(Caravan.deny_invitation(c1.caravan_id, 334)).to eq $SUCCESS

    expect(Caravan.get_participants(c1.caravan_id).count).to eq 1
  end

  it "should error on caravan deny/accepts properly" do
    u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
    u2 = User.create(user_id: 334, username:'a', password:'bbbbbb')
    c1 = Caravan.create_caravan(333)

    expect(Caravan.deny_invitation(c1.caravan_id, 334)).to eq $ERR_NO_EXISTING_INVITATION
    expect(Caravan.accept_invitation(c1.caravan_id, 334)).to eq $ERR_NO_EXISTING_INVITATION

    expect(Caravan.invite_user(c1.caravan_id, 334)).to eq $SUCCESS
    expect(Caravan.deny_invitation(c1.caravan_id, 334)).to eq $SUCCESS

    expect(Caravan.deny_invitation(c1.caravan_id, 334)).to eq $ERR_NO_EXISTING_INVITATION
    expect(Caravan.accept_invitation(c1.caravan_id, 334)).to eq $ERR_NO_EXISTING_INVITATION

    expect(Caravan.invite_user(c1.caravan_id, 334)).to eq $SUCCESS
    expect(Caravan.accept_invitation(c1.caravan_id, 334)).to eq $SUCCESS

    expect(Caravan.deny_invitation(c1.caravan_id, 334)).to eq $ERR_NO_EXISTING_INVITATION
    expect(Caravan.accept_invitation(c1.caravan_id, 334)).to eq $ERR_NO_EXISTING_INVITATION
  end

  it "should not be able to remove host from caravan" do
    u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
    c1 = Caravan.create_caravan(333)

    expect(Caravan.get_participants(c1.caravan_id).count).to eq 1
    expect(Caravan.remove_user(c1.caravan_id, 333)).to eq $ERR_HOST_CANNOT_BE_REMOVED
    expect(Caravan.get_participants(c1.caravan_id).count).to eq 1
  end
    
  it "should remove caravan users properly" do
    u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
    u2 = User.create(user_id: 334, username:'a', password:'bbbbbb')
    c1 = Caravan.create_caravan(333)

    expect(Caravan.get_participants(c1.caravan_id).count).to eq 1
    
    Caravan.invite_user(c1.caravan_id, 334)
    Caravan.accept_invitation(c1.caravan_id, 334)

    expect(Caravan.get_participants(c1.caravan_id).count).to eq 2

    expect(Caravan.remove_user(c1.caravan_id, 334)).to eq $SUCCESS
    expect(Caravan.get_participants(c1.caravan_id).count).to eq 1
  end

  it "should error properly when removing non users" do
    u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
    u2 = User.create(user_id: 334, username:'a', password:'bbbbbb')
    c1 = Caravan.create_caravan(333)
    
    Caravan.invite_user(c1.caravan_id, 334)
    Caravan.deny_invitation(c1.caravan_id, 334)
    expect(Caravan.get_participants(c1.caravan_id).count).to eq 1

    expect(Caravan.remove_user(c1.caravan_id, 334)).to eq $ERR_USER_NOT_IN_CARAVAN
    expect(Caravan.get_participants(c1.caravan_id).count).to eq 1
  end

  it "should not return a caravan that doesnt exist" do
    u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
    c1 = Caravan.create_caravan(333)

    expect(Caravan.get_caravan(c1.caravan_id + 1)).to eq $ERR_CARAVAN_DOESNT_EXIST
    expect(Caravan.get_caravan(c1).is_a? Integer).to eq false
  end

  it "should return proper list for get_participants" do
    u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
    u2 = User.create(user_id: 334, username:'a', password:'bbbbbb')
    u3 = User.create(user_id: 335, username:'a', password:'bbbbbb')
    c1 = Caravan.create_caravan(333)
    Caravan.invite_user(c1.caravan_id, 334)
    Caravan.invite_user(c1.caravan_id, 335)
    Caravan.accept_invitation(c1.caravan_id, 334)
    Caravan.accept_invitation(c1.caravan_id, 335)

    user_ids = Caravan.get_participants(c1.caravan_id)
    expect(user_ids.include? 332).to eq false
    expect(user_ids.include? 333).to eq true
    expect(user_ids.include? 334).to eq true
    expect(user_ids.include? 335).to eq true
    expect(user_ids.include? 336).to eq false
  end

end
