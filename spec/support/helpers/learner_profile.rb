require_relative "./image_file_mock"

module LearnerProfileHelper
  def update_bootcamper_avatar(camper_id, value)
    if value.nil? || value.is_a?(String) && camper_id.is_a?(String)
      bootcamper = Bootcamper.find_by(camper_id: camper_id)
      bootcamper.avatar = value
      bootcamper.save
    end
  end

  def edit_upload_image_file(filename = nil, size = nil)
    ImageFile.new(filename, size)
  end

  def populate_assessments
    {
      upload_submission: create_submission("file"),
      link_submission: create_submission("link"),
      dual_submission: create_submission("file, link"),
      late_submission: create_submission("file, link"),
      with_phases: create_submission("link", true)
    }
  end

  def create_submission(type, with_submissions = false)
    assessment = create :assessment, :requires_submissions, :long_description,
                        phases: [@phase],
                        submission_types: type,
                        requires_submission: true,
                        framework_criterium_id: @framework_criterium.id,
                        with_submissions: with_submissions
    assessment
  end

  def enter_submission
    find("a#phases-tab").click
    find("#accordion-title-#{@framework_criterium.framework_id}").click
  end

  def fill_in_link(day, link = "https://github.com")
    find("#submit-for-#{@assessments[:with_phases].id}").click
    find("a", text: day).click
    fill_in "link", with: link
    fill_in "description", with: "this is the description"
    find("a#save-learner-submission").click
  end
end
