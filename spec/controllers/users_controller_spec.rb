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
    let(:time) { 5.days.ago }
    let(:tweet1) do
      instance_double(
        Twitter::Tweet,
        text: "First tweet",
        retweet_count: 1,
        created_at: time
      )
    end
    let(:tweet2) do
      instance_double(
        Twitter::Tweet,
        text: "Second tweet",
        retweet_count: 0,
        created_at: time - 2.minutes
      )
    end
    let(:tweets) { [tweet1, tweet2] }

    before do
      allow_any_instance_of(TwitterAgent).to(
        receive(:recent_tweets).and_return(tweets)
      )
    end

    it "gets the recent tweets from TwitterAgent" do
      expect_any_instance_of(TwitterAgent).to(
        receive(:recent_tweets).with(handle)
      )
      get :recent_tweets, handle: handle
    end

    it "returns all of the tweets" do
      get :recent_tweets, handle: handle
      expect(json_response_body.size).to eq(tweets.size)
    end

    it "filters by min_retweets" do
      get :recent_tweets, handle: handle, min_retweets: 1
      expect(json_response_body.size).to eq(1)
    end
  end
end
