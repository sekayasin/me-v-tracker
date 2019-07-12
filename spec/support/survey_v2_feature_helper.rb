require "capybara"

module Helpers
  def create_survey_bootcamper
    @bootcamper = create(:bootcamper)
    @cycle_center = create(:cycle_center)
    create(
      :learner_program,
      camper_id: @bootcamper.camper_id,
      cycle_center_id: @cycle_center.cycle_center_id
    )
  end

  def stub_different_users
    stub_non_andelan_bootcamper @bootcamper
    stub_current_session_bootcamper @bootcamper
  end

  def populate_question_helper(option)
    fill_in("Enter Title", with: "First general survey")
    expect(page).to have_content("First general survey")
    page.first(".select-shelter").click
    within(".options-wrapper") do
      within(".options-list") do
        find(".option:nth-child(#{option})").click
      end
    end
  end

  def change_question_helper(option)
    find(".select-shelter").click
    within(".options-wrapper") do
      within(".options-list") do
        find(".option:nth-child(#{option})").click
      end
    end
  end

  def goto_survey_page
    find("#new-survey-btn").click
  end

  def fill_question_with(choice)
    fill_in("Type Your Question...",
            with: "This is a  #{choice} question", exact: true)
  end

  def add_row_and_column
    fill_in("Add A Row", with: "row1")
    find("#row-addon").native.send_keys(:return)
    fill_in("Add A Column", with: "col1")
    find("#column-addon").native.send_keys(:return)
    fill_in("Add A Column", with: "col2")
    find("#column-addon").native.send_keys(:return)
    fill_in("Add A Row", with: "row1")
    find("#row-addon").native.send_keys(:return)
  end

  def add_section
    find("#add-section-btn-0").click
  end

  def add_choice
    fill_in("Add A Choice", with: "choice1")
    find(".add-choice").native.send_keys(:return)
    fill_in("Add A Choice", with: "choice2")
    find(".add-choice").native.send_keys(:return)
  end

  def reorder_survey(section_id, type_id)
    within("#section-#{section_id}") do
      find(".section-options .more-icon").hover
      find(type_id.to_s).click
    end
  end

  def populate_and_link_section
    populate_question_helper(2)
    add_choice
    find("#add-section-btn-0").click
    find("#section-1 .more-icon").hover
    find("#link-question").click
    find("#section-link-dropdown-button").click
    find(".ui-menu-item", text: "Section 1").click
    find("#question-link-dropdown-button").click
    find(".ui-menu-item", text: "Question 1").click
    find("#option-link-dropdown-button").click
    find(".ui-menu-item", text: "Option 2: choice2").click
    find("#link-confirm-btn").click
  end

  def save_file(file_name)
    @bucket = GcpService::SURVEY_MEDIA_BUCKET
    @connection = Fog::Storage.new(
      provider: "AWS",
      aws_access_key_id: "access key",
      aws_secret_access_key: "secret key"
    )
    allow(GcpService).to receive(:get_connection).and_return(@connection)
    @connection.put_bucket(@bucket)
    GcpService.upload(file_name.to_s, file_name.to_s, @bucket)
  end

  def upload_images
    upload_output_file("fullsizeoutput_3b copy.jpeg", "add-file-question-0")
    upload_output_file("fullsizeoutput_3b copy.jpeg", "add-file-question-0")
    save_file("fullsizeoutput_3b copy")
  end

  def select_program
    visit("/")
    find("a.dropdown-input").click
    find("ul#index-dropdown li a.dropdown-link").click
    find("img.proceed-btn").click
    visit("/surveys-v2")
  end

  def save_survey
    find("#survey-share-btn").click
    page.execute_script("$('#survey_share_start_date').val('21/12/2019')")
    page.execute_script("$('#survey_share_end_date').val('28/12/2019')")
    page.all(".select-shelter").last.click
    find(".cycle-options-list").click
    find(".send-button").click
  end

  def update_survey
    find("#survey-share-btn").click
    sleep 1
    page.execute_script("$('#survey_share_start_date').val('21/12/2019')")
    page.execute_script("$('#survey_share_end_date').val('28/12/2019')")
    page.all(".select-shelter").last.click
    find(".cycle-options-list").click
    find(".update-btn-shelter").click
    expect(page).to have_content("Successfully updated survey")
  end

  def populate_edit_survey
    first("#new-survey-btn").click
    sleep 1
    populate_question_helper("5")
    fill_question_with("scale")
    find(".mdl-slider").set(6).click
    expect(page).to have_selector(".question-wrapper")
    save_survey
    first(".survey-card .more-icon").hover
    first(".survey-card #edit-form").click
    visit("/surveys-v2/#{@survey.id}/edit")
    expect(page).to have_selector("#add-question-btn-0")
  end

  def save_survey_without_date
    find(".btn-survey-share").click
    page.all(".select-shelter").last.click
    find(".cycle-options-list").click
    find(".send-button").click
    expect(page).to have_content("Please provide the start and end date")
  end

  def save_survey_with_invalid_schedule
    find(".btn-survey-share").click
    page.execute_script(
      "$('#survey_share_start_date').val('30 Dec 2019 13:00')"
    )
    page.execute_script(
      "$('#survey_share_end_date').val('25 Dec 2019 17:05')"
    )
    page.all(".select-shelter").last.click
    find(".cycle-options-list").click
    find(".send-button").click
  end

  def assert_content(content_array)
    content_array.each do |content|
      expect(page).to have_content content
    end
  end

  def assert_selectors(ids)
    ids.each do |id|
      expect(page).to have_selector id
    end
  end

  def save_survey_draft
    find("#survey-share-btn").click
    find("#survey-save-progress").click
    expect(page).to have_content("Successfully saved draft")
  end
end
