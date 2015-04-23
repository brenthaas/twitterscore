require 'rails_helper'

describe UsersController do
  let(:handle) { 'loquie' }

  it "displays a user" do
    VCR.use_cassette('get user loquie') do
      get :profile, handle: handle
    end
    expect(response.status).to eq(200)
    expect(json_response_body['screen_name']).to eq(handle)
  end

  it "requires that handle param is passed" do
    get :profile, handle: ''
    expect(response.status).to eq(422)
  end
end
