require "rails_helper"

describe CaravansController do
  it "should be -1 for nonexistent caravan" do
    get 'show', :id => 3
    body = JSON.parse(response.body)
    expect(body['reply_code'] == -1).to eq true
  end

  it "should be 1 for existing caravan" do
    u1 = User.create(user_id: 333, username:'a', password:'bbbbbb')
    c1 = Caravan.create_caravan(333)
    
    get 'show', :id => c1.caravan_id
    puts c1.caravan_id
    body = JSON.parse(response.body)
    puts body
    expect(body['reply_code'] == 1).to eq true
    expect(body['id'] == c1.caravan_id).to eq true
    expect(body['host_id'] == c1.host_user_id).to eq true
  end
    
end
