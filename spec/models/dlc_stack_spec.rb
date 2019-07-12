require "rails_helper"

RSpec.describe DlcStack, type: :model do
  describe "Validations" do
    it { is_expected.to belong_to(:program) }
    it { is_expected.to belong_to(:language_stack) }
    it { is_expected.to have_many(:learner_programs) }
  end

  describe "when validating fields" do
    it { is_expected.to validate_presence_of(:program_id) }
    it { is_expected.to validate_presence_of(:language_stack_id) }
  end

  let(:program) { create :program }
  let(:language_stack) { create :language_stack }

  describe ".save_dlc_language" do
    context "when program does not have a dlc_language" do
      it "dlc_language should be empty" do
        expect(DlcStack.where(program_id: program.id)).to be_empty
      end
    end

    context "when a program dlc language does not exist" do
      it "saves the dlc_language for the program" do
        DlcStack.save_dlc_language(program.id, [language_stack.id])
        expect(DlcStack.where(program_id: program.id).count).to eql(1)
      end
    end

    context "when a program has a dlc language" do
      it "does not duplicate the dlc language" do
        3.times do
          DlcStack.save_dlc_language(program.id, [language_stack.id])
        end
        dlc_language = DlcStack.where(
          program_id: program.id,
          language_stack_id: language_stack.id
        )
        expect(dlc_language.size).to eql(1)
      end
    end
  end

  describe ".show_program_dlc_stack" do
    let!(:dlc_stack) { create :dlc_stack, program: program }

    it "gets all dlc stack associated with the program" do
      dlc_stacks = DlcStack.show_program_dlc_stack(program.id)
      expect(dlc_stacks.last).to eql dlc_stack
    end
  end
end
