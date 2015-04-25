require 'rails_helper'

describe UsersController do
  let(:handle) { 'loquie' }

  describe "#profile" do

    before do
      allow_any_instance_of(TwitterAgent).to receive(:score).and_return(30)
    end

    it "gets the profile from TwitterAgent" do
      expect_any_instance_of(TwitterAgent).to(
        receive(:profile).with(handle).and_return({})
      )
      get :profile, handle: handle
    end
  end

  describe "#recent_tweets" do
    it "gets the recent tweets from TwitterAgent" do
      expect_any_instance_of(TwitterAgent).to(
        receive(:recent_tweets).with(handle)
      )
      get :recent_tweets, handle: handle
    end
  end
end
