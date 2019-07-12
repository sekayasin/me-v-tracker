require "rails_helper"

RSpec.describe OutputSubmission, type: :model do
  let(:learner_program) { create :learner_program }
  let(:assessment) { create :assessment_with_phases }

  let(:total_links) do
    OutputSubmission.where(learner_programs_id: learner_program.id).count
  end

  context "when validating associations" do
    it { is_expected.to belong_to(:learner_program) }
    it { is_expected.to belong_to(:assessment) }
    it { is_expected.to belong_to(:submission_phase) }
    it { is_expected.to belong_to(:phase) }
  end

  context "when validating links" do
    it { should allow_value("http://medium.com/@user/post").for(:link) }
    it { should allow_value("https://www.github.com/user/repo").for(:link) }
    it { should allow_value("https://trello.com/b/board").for(:link) }
    it { should allow_value("http://google.com").for(:link) }
  end

  describe ".total_links_submitted" do
    it "returns the total number of links the learner has submitted" do
      total_submissions = OutputSubmission.
                          total_links_submitted(learner_program.id)
      expect(total_submissions).to eql total_links
    end
  end

  describe "Validating submission types" do
    context "when assessment requires link only" do
      let(:assessment_requiring_link) do
        create(:assessment_with_phases,
               requires_submission: true,
               submission_types: "link")
      end
      let(:output_submission) do
        build(:output_submission,
              link: nil,
              file_link: "https://storage.googleapis.test.com",
              learner_program: learner_program,
              assessment: assessment_requiring_link,
              phase: assessment_requiring_link.phases[1])
      end
      it "is invalid without any link provided" do
        expect(output_submission.valid?).to eq(false)
        expect(output_submission.errors[:link]).to include("must be provided")
      end

      it "is invalid with a wrong link" do
        output_submission.link = "1234"
        error = "must be a valid http:// or https:// url"
        expect(output_submission.valid?).to eq(false)
        expect(output_submission.errors[:link]).to include(error)
      end

      it "is valid with the right link and saves successfully" do
        output_submission.link = "https://www.github.com"
        expect(output_submission.valid?).to eq(true)
        expect(output_submission.save).to eq(true)
      end
    end

    context "when the assessment requires a file upload" do
      let(:assessment) do
        create(:assessment_with_phases,
               requires_submission: true,
               submission_types: "file")
      end
      let(:output_submission) do
        build(:output_submission,
              link: "https://www.github.com",
              learner_program: learner_program,
              assessment: assessment,
              phase: assessment.phases[1])
      end
      it "is invalid without any file provided" do
        error = "must be provided"
        expect(output_submission.valid?).to eq(false)
        expect(output_submission.errors[:file_link]).to include(error)
      end

      it "is valid with the right file and saves successfully" do
        output_submission.file_link = "https://storage.googleapis.test.com"
        expect(output_submission.valid?).to eq(true)
        expect(output_submission.save).to eq(true)
      end
    end

    context "when the assessment requires a file upload or description" do
      let(:assessment) do
        create(:assessment_with_phases,
               requires_submission: true,
               submission_types: "file, link")
      end
      let(:output_submission) do
        build(:output_submission,
              link: nil,
              file_link: nil,
              learner_program: learner_program,
              assessment: assessment,
              phase: assessment.phases[1])
      end
      it "is invalid without any file or link provided" do
        error = "should contain a file or a link"
        expect(output_submission.valid?).to eq(false)
        expect(output_submission.errors[:Submission]).to include(error)
      end

      it "is valid with the right file and saves successfully" do
        output_submission.link = "https://storage.googleapis.test.com"
        expect(output_submission.valid?).to eq(true)
        expect(output_submission.save).to eq(true)
      end
    end
  end
end
