class TwitterAgent
  def initialize(client)
    @client = client
  end

  def profile(user)
    @client.user(user)
  end

  def score(user)
    score = score_user(user)
    follower_score = followers(user).reduce(0) { |sum, u| sum += score_user(u) }
    (score * 2) + follower_score
  end

  def recent_tweets(user, count= 50)
    begin
      @client.user_timeline(user, {count: count})
    rescue Twitter::Error::Unauthorized
      []
    end
  end

  def followers(user)
    @client.followers(user).map(&:screen_name)
  end

  private

  def score_user(user)
    recent_tweets(user).map(&:text).reduce(0) do |sum, tweet|
      sum += score_text(tweet)
    end || 0
  end

  def score_text(text)
    words = text.split(/[^\w\-@]+/)
    word_counts = words.each_with_object(Hash.new(0)) do |word, counts|
      counts[word] += 1
    end
    score_word_counts(word_counts)
  end

  def score_word_counts(word_counts)
    word_counts.reduce(0) do |sum, (word, count)|
      weight = WeightedWord.find_by_word(word.downcase).try(:weight) || 0
      sum += weight * count
    end
  end
end
