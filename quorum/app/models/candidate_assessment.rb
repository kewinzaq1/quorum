class CandidateAssessment < ApplicationRecord
  belongs_to :candidate
  belongs_to :participant

  validates :participant_id, uniqueness: { scope: :candidate_id }
end
