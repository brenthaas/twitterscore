class TwitterAgent
  def initialize(client)
    @client = client
  end

  def profile(user)
    @client.user(user)
  end

  def recent_tweets(user, count= 50)
    @client.user_timeline(user, {count: count})
  end

  def score_text(text)
    words = text.split(/\W+/)
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
