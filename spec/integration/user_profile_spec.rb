require 'rails_helper'

describe "Getting a user profile" do
  let(:handle) { 'loquie' }
  let(:fields) { %w(name screen_name location reputation_score) }

  it "responds with all necessary fields" do
    VCR.use_cassette("get user #{handle}") do
      get "/users/#{handle}/profile"
    end

    fields.each do |field|
      expect(json_response_body.keys).to include(field)
    end
  end
end
