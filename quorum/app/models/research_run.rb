class ResearchRun < ApplicationRecord
  belongs_to :lunch_room
  has_many :candidates, dependent: :destroy
  has_many :sources, dependent: :destroy

  enum :status, {
    queued: 0,
    searching: 1,
    reading: 2,
    reasoning: 3,
    completed: 4,
    failed: 5
  }

  validates :provider, presence: true

  def terminal?
    completed? || failed?
  end

  def demo?
    provider == "demo"
  end
end
