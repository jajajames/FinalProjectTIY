class Report < ActiveRecord::Base
  belongs_to :journey
  attachment :image, type: :image
  validates_inclusion_of :survey, in: 1..10, allow_blank: true

  default_scope { order(created_at: :asc) }

  def self.parse_text(text)
    words = text.split
    surveys = Hash.new
    words.each_with_index do |word, index|
      word.downcase!
      if word == 'b' || word == 'before'
        surveys[:pre] = words[index + 1]
      elsif word == 'a' || word == 'after'
        surveys[:post] = words[index + 1]
      end
    end
    surveys
  end
end
