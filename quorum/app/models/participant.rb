class Participant < ApplicationRecord
  belongs_to :lunch_room
  has_many :candidate_assessments, dependent: :destroy

  validates :name, presence: true
  validates :max_walk_minutes, numericality: { greater_than: 0, less_than_or_equal_to: 60 }, allow_nil: true
  validates :budget_cents, numericality: { greater_than: 0 }, allow_nil: true

  def budget_dollars
    budget_cents / 100 if budget_cents.present?
  end

  def constraints
    [
      diet.presence,
      dislikes.present? ? "avoids #{dislikes}" : nil,
      max_walk_minutes.present? ? "#{max_walk_minutes} min walk" : nil,
      budget_cents.present? ? "$#{budget_dollars} max" : nil,
      hard_stop.present? ? "back by #{hard_stop.strftime("%-I:%M %p")}" : nil
    ].compact
  end
end
