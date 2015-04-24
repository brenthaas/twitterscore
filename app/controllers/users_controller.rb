class UsersController < ApplicationController

  def profile
    render json: agent.profile(params.require(:handle))
  end

  def recent_tweets
    timeline = agent.recent_tweets(params.require(:handle))
    if params[:min_retweets].present?
      timeline = filter_by_retweet_count(timeline, params[:min_retweets])
    end
    render json: timeline, only: [:created_at, :text, :retweet_count]
  end

  private

  def agent
    @client ||= TwitterAgent.new(twitter_client)
  end

  def filter_by_retweet_count(tweets, min_retweets)
    tweets.select { |twt| twt.retweet_count >= min_retweets }
  end

  def filter_by_tweet_age(tweets, time)
    tweets.select { |twt| twt.creted_at < time }
  end
end
