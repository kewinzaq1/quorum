class Source < ApplicationRecord
  belongs_to :research_run
  belongs_to :candidate

  validates :url, :title, presence: true
end
