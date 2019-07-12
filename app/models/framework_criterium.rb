class FrameworkCriterium < ApplicationRecord
  belongs_to :criterium, -> { with_deleted }
  belongs_to :framework
  has_many :assessments, -> { with_deleted }
end
