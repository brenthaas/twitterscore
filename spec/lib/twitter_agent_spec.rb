require 'rails_helper'

describe TwitterAgent do
  let(:client) { double Twitter::REST::Client }
  let(:user) { 'loquie' }

  subject { described_class.new(client) }

  describe "#profile_for" do
    it "looks up a user" do
      expect(client).to receive(:user).with(user)
      subject.profile(user)
    end
  end

  describe "#recent_tweets" do
    let(:default_options) { {count: 50} }
    let(:time) { 5.days.ago }
    let(:old_tweet) do
      instance_double(Twitter::Tweet,
                        retweet_count: 0,
                        created_at: time - 1.minute)
    end
    let(:retweeted_tweet) do
      instance_double(Twitter::Tweet, retweet_count: 1, created_at: time)
    end

    let(:fake_tweets) { [retweeted_tweet, old_tweet] }

    before do
      allow(client).to receive(:user_timeline).and_return(fake_tweets)
    end

    it "gets the user timeline" do
      expect(client).to receive(:user_timeline).with(user, default_options)
      subject.recent_tweets(user)
    end
  end
end
