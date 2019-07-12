require "rails_helper"

RSpec.describe Bootcamper, type: :model do
  context "when validating fields" do
    subject do
      Bootcamper.new(
        camper_id: Bootcamper.includes(:learner_programs).generate_camper_id
      )
    end

    it { is_expected.to validate_uniqueness_of(:camper_id) }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:gender) }
    it { is_expected.to validate_acceptance_of(:gender) }
    it { is_expected.to validate_uniqueness_of(:email) }
    it { is_expected.to validate_uniqueness_of(:uuid).case_insensitive }
  end

  context "when validating associations" do
    associations = %i[
      bootcampers_language_stacks
      language_stacks
      learner_programs
      programs
    ]

    associations.each do |association|
      it { is_expected.to have_many(association) }
    end

    it { is_expected.to belong_to(:proficiency) }
  end

  describe ".generate_camper_id" do
    context "when generating camper id" do
      it "returns a string" do
        expect(Bootcamper.generate_camper_id).to be_a(String)
      end

      it "returns a unique string" do
        first_camper_id = Bootcamper.generate_camper_id
        second_camper_id = Bootcamper.generate_camper_id

        expect(first_camper_id).not_to eq(second_camper_id)
      end
    end
  end

  describe ".search" do
    let(:program) { create :program }
    let(:bootcamper) { create :bootcamper }

    context "when results does not match search criteria" do
      it "returns empty result" do
        search_term = "8xeaa23422"
        expect(Bootcamper.search(search_term, program.id).length).to eq(0)
      end
    end

    context "when results match search criteria" do
      let(:first_bootcamper_with_learner_program) do
        create(
          :learner_program,
          program: program,
          bootcamper: bootcamper
        )
      end

      it "returns one camper that matches search criteria" do
        first_bootcamper_with_learner_program
        search_term = bootcamper.email

        expect(Bootcamper.search(search_term, program.id).length).to eq(1)
      end

      it "returns all campers that match search criteria" do
        first_bootcamper_with_learner_program
        second_bootcamper = create(:bootcamper,
                                   last_name: bootcamper.first_name)

        create(
          :learner_program,
          program: program,
          bootcamper: second_bootcamper
        )

        search_term = bootcamper.first_name
        search_result = Bootcamper.search(search_term, program.id)

        expect(search_term).to eq(search_result.first.bootcamper.first_name)
        expect(search_result.length).to eq(2)
      end
    end
  end

  describe ".learner_details" do
    it "returns learner" do
      learner = create(:bootcamper_with_learner_program)
      learner_program_id = learner.learner_programs.ids[0]
      result = Bootcamper.learner_details(learner_program_id)

      expect(learner.camper_id).to eq(result.bootcamper.camper_id)
    end
  end

  describe "#name" do
    context "when a camper has been created" do
      it "returns the camper's full name" do
        learner = create(:bootcamper)

        expect(learner.name).to eq(
          "#{learner.first_name} #{learner.last_name}"
        )
      end
    end
  end

  describe ".arrange_learner" do
    it "returns an array of camper's information for all programs attended" do
      first_learner = create(:bootcamper_with_learner_program)

      expect(Bootcamper.arrange_learners(
        first_learner.learner_programs
      ).length).to eq(1)
    end
  end

  describe ".validate_camper" do
    context "when a record is passed" do
      it "returns a record if it exists or creates a new record" do
        learner = create(:bootcamper)
        expect(Bootcamper.validate_camper(learner)).to eq(learner)
      end
    end
  end

  describe ".get_decsison_comment" do
    before do
      @learner_program = create(:learner_program)
      @decision_one = create(
        :decision,
        decision_stage: 1,
        learner_programs_id: @learner_program.id
      )
      @decision_two = create(
        :decision,
        decision_stage: 2,
        learner_programs_id: @learner_program.id
      )
    end

    context "when the decsion stage is 1" do
      it "returns the comment for decision one" do
        expect(
          Bootcamper.get_decision_comment([@decision_one, @decision_two], 1)
        ).to eq(@decision_one.comment)
      end
    end

    context "when the decsion stage is 2" do
      it "returns the comment for decision two" do
        expect(
          Bootcamper.get_decision_comment([@decision_one, @decision_two], 2)
        ).to eq(@decision_two.comment)
      end
    end
  end
end
