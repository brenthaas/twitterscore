require 'rails_helper'

describe "Getting a user profile" do
  let(:handle) { 'loquie' }
  let(:fields) { %w(name screen_name location) }

  it "responds with all necessary fields" do
    VCR.use_cassette("get user #{handle}") do
      get "/users/#{handle}/profile"
    end

    fields.each do |field|
      expect(json_response_body.keys).to include(field)
    end
  end
end

describe "Getting a user score" do
  let(:handle) { 'loquie' }

  it "responds with all necessary fields" do
    VCR.use_cassette("score user #{handle}") do
      get "/users/#{handle}/score"
    end

    expect(json_response_body.keys).to include('reputation_score')
  end
end
