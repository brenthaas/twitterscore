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

  describe "#score_text" do
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

    shared_examples "gets the correct sum" do
      it { expect(subject.score_text(text)).to eq(score) }
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
  end
end
