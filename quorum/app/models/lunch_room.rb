class LunchRoom < ApplicationRecord
  has_many :participants, dependent: :destroy
  has_many :research_runs, dependent: :destroy
  has_many :candidates, dependent: :destroy
  belongs_to :locked_candidate, class_name: "Candidate", optional: true
  belongs_to :backup_candidate, class_name: "Candidate", optional: true

  enum :status, { collecting: 0, researching: 1, ready: 2, locked: 3 }

  validates :name, :origin_text, presence: true
  validates :public_token, presence: true, uniqueness: true
  validates :group_budget_cents, numericality: { greater_than: 0 }, allow_nil: true
  validate :return_after_lunch

  before_validation :assign_public_token, on: :create

  def to_param
    public_token
  end

  def group_budget_dollars
    group_budget_cents.to_i / 100
  end

  private

  def assign_public_token
    self.public_token ||= SecureRandom.urlsafe_base64(8)
  end

  def return_after_lunch
    return unless lunch_at && return_by && return_by <= lunch_at

    errors.add(:return_by, "must be after lunch starts")
  end
end
