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

  before(:each) do
    @r = User.register("testusername", "testpassword")
    @l = User.login("testusername", "testpassword")
  end

  it "should not allow a user to login if the credentials are incorrect" do
    login = User.login("testusername", "wrongpassword")
    expect(login[:reply_code]).to be == ERR_BAD_CREDENTIALS
  end

  it "should login if the credentials are correct" do
    expect(@l[:reply_code]).to be == SUCCESS
  end

  it "should register the user successfully" do
    expect(@r[:reply_code]).to be == SUCCESS
  end

  it "should not allow usernames less than MIN_USERNAME_LENGTH" do
    reg = User.register("test", "testpassword")
    expect(reg[:reply_code]).to be == ERR_INVALID_USERNAME
  end

  it "should not allow usernames greater than MAX_USERNAME_LENGTH" do
    reg = User.register("testtesttesttesttest", "testpassword")
    expect(reg[:reply_code]).to be == ERR_INVALID_USERNAME
  end

  it "should not allow passwords less than MIN_PASSWORD_LENGTH" do
    reg = User.register("testusername", "test")
    expect(reg[:reply_code]).to be == ERR_INVALID_PASSWORD
  end

  it "should not allow passwords greater than MAX_PASSWORD_LENGTH" do
    reg = User.register("testusername", "testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttest1")
    expect(reg[:reply_code]).to be == ERR_INVALID_PASSWORD
  end

  it "should return an error code if trying to retrieve a user that doesn't exit" do
    u = User.getUser(-1)
    expect(u[:reply_code]).to be == ERR_USER_DOESNT_EXIST
  end

  it "should return a user" do
    u = User.getUser(@l[:user_id])
    expect(u[:reply_code]).to be == SUCCESS
  end 
  
end