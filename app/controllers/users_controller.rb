class UsersController < ApplicationController

  def profile
    render json: agent.profile(handle)
  end

  def recent_tweets
    timeline = agent.recent_tweets(handle)
    if params[:min_retweets].present?
      timeline = filter_by_retweet_count(timeline, params[:min_retweets].to_i)
    end
    formatted_hash = format_timeline(timeline)
    render json: formatted_hash
  end

  def score
    render json: { reputation_score: agent.score(handle) }
  end

  private

  def agent
    @client ||= TwitterAgent.new(twitter_client)
  end

  def handle
    params.require(:handle)
  end

  def format_timeline(timeline)
    fields = %i(created_at text retweet_count)
    timeline.map do |post|
      pruned = post.to_h.select {|key,_| fields.include? key }
      pruned[:media_urls] = if post.media
        post.media.map do |m|
          url = m.media_url
          url.scheme + "://" + url.host + url.path
        end
      else
        []
      end
      pruned
    end
  end

  def filter_by_retweet_count(tweets, min_retweets)
    tweets.select { |twt| twt.retweet_count >= min_retweets }
  end

  def filter_by_tweet_age(tweets, time)
    tweets.select { |twt| twt.creted_at < time }
  end
end
