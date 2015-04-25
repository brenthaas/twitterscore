require 'rails_helper'

describe TwitterAgent do
  let(:client) { double Twitter::REST::Client }
  let(:user) { 'loquie' }

  subject { described_class.new(client) }

  describe "#profile" do
    before do
      allow(client).to receive(:user_timeline).and_return([])
      allow(client).to receive(:followers).and_return([])
    end

    it "looks up a user" do
      expect(client).to receive(:user).with(user)
      subject.profile(user)
    end
  end

  describe "#score" do
    let(:follower_name) { 'fan' }
    let(:follower) { double(Twitter::User, screen_name: follower_name) }

    before do
      allow(client).to receive(:followers).and_return([follower])
      allow(subject).to receive(:score_user).with(user).and_return(10)
      allow(subject).to receive(:score_user).with(follower_name).and_return(5)
    end

    it "scores the user and their followers" do
      expect(subject.score(user)).to eq 25
    end
  end

  describe "#followers" do
    let(:follower1) { instance_double(Twitter::User, screen_name: "foo") }
    let(:followers) { [follower1] }

    before { allow(client).to receive(:followers).with(user).and_return(followers) }

    it "gives a list of the screen_names of followers" do
      expect(subject.followers(user)).to eq(['foo'])
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

  describe "scoring tweets" do
    let(:positive_words) { %w(happy joy) }
    let(:negative_words) { %w(boo hate) }

    before do
      positive_words.each do |word|
        WeightedWord.create(word: word, weight: 1)
      end
      negative_words.each do |word|
        WeightedWord.create(word: word, weight: -1)
      end
    end

    describe "#score_user" do
      let(:tweet1_text) { "Happy, happy, Joy, joy! Joy & Happy" }
      let(:tweet1_score) { 6 }
      let(:tweet1) { double(Twitter::Tweet, text: tweet1_text) }
      let(:tweet2_text) { "Boo, I hate this" }
      let(:tweet2_score) { -2 }
      let(:tweet2) { double(Twitter::Tweet, text: tweet2_text) }
      let(:tweets) { [tweet1, tweet2] }
      let(:total_score) { tweet1_score + tweet2_score }

      before { allow(subject).to receive(:recent_tweets).and_return(tweets) }

      it "scores the users tweets" do
        expect(subject.send(:score_user, user)).to eq(total_score)
      end
    end

    describe "#score_text" do
      shared_examples "gets the correct sum" do
        it { expect(subject.send(:score_text, text)).to eq(score) }
      end

      context "with positive words" do
        let(:text) { "happy people happy joy" }
        let(:score) { 3 }

        it_behaves_like "gets the correct sum"
      end

      context "with negative words" do
        let(:text) { "Boo I hate this" }
        let(:score) { -2 }

        it_behaves_like "gets the correct sum"
      end

      context "with punctuation" do
        let(:text) { "Happy, happy, (Joy) joy! Boo." }
        let(:score) { 3 }

        it_behaves_like "gets the correct sum"
      end

      context "with a weighted word name" do
        let(:text) { "I hate @happy" }
        let(:score) { -1 }

        it_behaves_like "gets the correct sum"
      end

      context "with a matching hyphenated word" do
        let(:negative_words) { %w(2-faced) }
        let(:text) { "2-faced" }
        let(:score) { -1 }

        it_behaves_like "gets the correct sum"
      end
    end
  end
end
