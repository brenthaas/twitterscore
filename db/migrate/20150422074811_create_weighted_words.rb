class CreateWeightedWords < ActiveRecord::Migration
  def change
    create_table :weighted_words do |t|
      t.string :word, index: true
      t.integer :weight

      t.timestamps null: false
    end
  end
end
