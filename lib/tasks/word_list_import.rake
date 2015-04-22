namespace :word_list do
  task import: [:environment] do
    negative_words_uri = URI('https://raw.githubusercontent.com/jeffreybreen/twitter-sentiment-analysis-tutorial-201107/master/data/opinion-lexicon-English/negative-words.txt')
    positive_words_uri = URI('https://raw.githubusercontent.com/jeffreybreen/twitter-sentiment-analysis-tutorial-201107/master/data/opinion-lexicon-English/positive-words.txt')
    puts "Adding positive words..."
    add_words(get_words(positive_words_uri), 1)
    puts "Adding negative words..."
    add_words(get_words(negative_words_uri), -1)
  end

  task clear: [:environment] do
    WeightedWord.destroy_all
  end
end

def get_words(uri)
 select_words(Net::HTTP.get(uri).split("\n")).map { |word| sanitize(word) }
end

def select_words(lines)
  lines.select{ |line| ! line.match(/^[; ]/) }
end

def sanitize(word)
  word.to_s.encode('UTF-8', {:invalid => :replace, :undef => :replace})
end

def add_words(words, weight)
  words.each do |word|
    WeightedWord.create(word: word, weight: weight)
  end
end
