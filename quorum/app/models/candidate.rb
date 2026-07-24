class Candidate < ApplicationRecord
  belongs_to :lunch_room
  belongs_to :research_run
  has_many :candidate_assessments, dependent: :destroy
  has_many :participants, through: :candidate_assessments
  has_many :sources, dependent: :destroy

  enum :status, { rejected: 0, viable: 1, selected: 2, backup: 3 }

  validates :name, presence: true
  validates :match_score, inclusion: { in: 0..100 }

  scope :ranked, -> { order(match_score: :desc, walk_minutes: :asc) }

  def price_label
    price_level.presence || "Price unknown"
  end
end
