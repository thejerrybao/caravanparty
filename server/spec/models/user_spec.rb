require 'rails_helper'

VAILD_USERNAME = "^[a-z][\w.]{5-17}$/i"
VALID_PASSWORD = ".{5, 64}"
SUCCESS = 1
ERR_USERNAME_EXISTS = -1
ERR_BAD_CREDENTIALS = -1
ERR_USER_DOESNT_EXIST = -1
ERR_USER_NOT_VISIBLE = -1
ERR_USER_NO_CARAVANS = -1
ERR_INVALID_PASSWORD = -2
ERR_INVALID_USERNAME = -3

describe Users do

  it "should not allow a user to login if the credentials are incorrect" do
    r = User.register("testusername", "testpassword")
    l = User.login("testusername", "wrongpassword")
    expect(l[:reply_code]).to be < 0
  end

  it "should login if the credentials are correct" do
    r = User.register("testusername", "testpassword")
    l = User.login("testusername", "wrongpassword")
    expect(l[:reply_code]).to be == 1
  end

  it "should register the user successfully" do
    r = User.register("testusername", "testpassword")
    expect(r[:reply_code]).to be == 1
  end

end