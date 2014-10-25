require 'rails_helper'

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

describe "Users" do

  it "should not allow a user to login if the credentials are incorrect" do
    r = User.register("testusername", "testpassword")
    l = User.login("testusername", "wrongpassword")
    expect(l[:reply_code]).to be == ERR_BAD_CREDENTIALS
  end

  it "should login if the credentials are correct" do
    r = User.register("testusername", "testpassword")
    l = User.login("testusername", "testpassword")
    expect(l[:reply_code]).to be == SUCCESS
  end

  it "should register the user successfully" do
    r = User.register("testusername", "testpassword")
    expect(r[:reply_code]).to be == SUCCESS
  end

  it "should not allow usernames less than MIN_USERNAME_LENGTH" do
    r = User.register("test", "testpassword")
    expect(r[:reply_code]).to be == ERR_INVALID_USERNAME
  end

  it "should not allow usernames greater than MAX_USERNAME_LENGTH" do
    r = User.register("testtesttesttesttest", "testpassword")
    expect(r[:reply_code]).to be == ERR_INVALID_USERNAME
  end

  it "should not allow passwords less than MIN_PASSWORD_LENGTH" do
    r = User.register("testusername", "test")
    expect(r[:reply_code]).to be == ERR_INVALID_PASSWORD
  end

  it "should not allow passwords greater than MAX_PASSWORD_LENGTH" do
    r = User.register("testusername", "testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttest1")
    expect(r[:reply_code]).to be == ERR_INVALID_PASSWORD
  end

end