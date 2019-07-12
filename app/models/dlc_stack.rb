class DlcStack < ApplicationRecord
  belongs_to :program
  belongs_to :language_stack
  has_many :learner_programs, foreign_key: :dlc_stack_id

  validates :program_id, presence: true
  validates :language_stack_id, presence: true

  def self.save_dlc_language(program_id, dlc_language)
    if dlc_language && !dlc_language.empty?
      dlc_language.each do |language_stack_id|
        find_or_create_by(
          program_id: program_id,
          language_stack_id: language_stack_id
        )
      end
    end
  end

  def self.show_program_dlc_stack(program_id)
    Program.includes(:dlc_stacks, :language_stacks).
      find_by_id(program_id).
      dlc_stacks
  end

  def self.copy_dlc_stacks(old_program_id, new_program_id)
    where(program_id: old_program_id).
      pluck(:language_stack_id).each do |language_id|
      create(program_id: new_program_id, language_stack_id: language_id)
    end
  end
end
