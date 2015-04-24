class TwitterAgent
  def initialize(client)
    @client = client
  end

  def profile(user)
    @client.user(user)
  end

  def recent_tweets(user, count= 50)
    tweets = @client.user_timeline(user, {count: count})
  end
end
