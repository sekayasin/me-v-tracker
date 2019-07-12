require_relative "panelist_get_all_learners_controller_helper.rb"

module CreatePitchHelper
  def create_seed_data
    pitch_create_program_helper
    create_pitch
  end

  def pitch_setup(_user, _session)
    visit("/")
    find("a.dropdown-input").click
    find("ul#index-dropdown li a.dropdown-link", text: @program.name).click
    find("img.proceed-btn").click
    visit("/pitch/#{@pitch.id}")
  end

  def setup_complete_ratings
    page.all(".panelist-card").first.click
    close_modal = page.all(".close_modal")
    if close_modal.count > 0
      close_modal.first.click
    end
    page.all(".radio-mark")[1].click
    page.all(".radio-mark")[7].click
    page.all(".radio-mark")[12].click
    page.all(".radio-mark")[17].click
    page.all(".radio-mark")[23].click
    page.execute_script("$('#yes').prop('checked', true)")
    fill_in("comment", with: "great work").click
    find("#learner_rating-container--submit-btn").click
    find("#continue-rating-btn").click
    sleep 1
    expect(current_path).to eq("/pitch/#{@pitch.id}")
  end

  def test_incomplete_ratings
    page.all(".panelist-card").first.click
    find(".close_modal").click
    fill_in("comment", with: "great work").click
    find("#learner_rating-container--submit-btn").click
    expect(page).to have_content("Kindly fill in the missing fields")
  end

  def create_pitch(panelist = "efe.love@andela.com", demo_date = Date.today + 1)
    @pitch1 = create(:pitch,
                     cycle_center_id: @cycle_center[:cycle_center_id],
                     demo_date: "2018-07-18",
                     created_by: "juliet@andela.com")
    @pitch = create(:pitch,
                    cycle_center_id: @cycle_center[:cycle_center_id],
                    created_by: "juliet@andela.com",
                    demo_date: demo_date)
    create(:panelist,
           pitch_id: @pitch1[:id],
           email: "efe.love@andela.com")
    @panelist = create(:panelist,
                       pitch_id: @pitch[:id],
                       email: panelist)
    @campers.map do |camper|
      @learners_pitch = create(:learners_pitch,
                               pitch_id: @pitch[:id],
                               camper_id: camper[:camper_id])
    end
  end

  def clear_seed_data
    Rating.destroy_all
    Pitch.where(
      cycle_center_id: @cycle_center[:cycle_center_id]
    ).destroy_all
    LearnerProgram.where(
      cycle_center_id: @cycle_center[:cycle_center_id]
    ).destroy_all
    @learner_program.destroy
    @cycle_center.destroy
    @campers.map(&:destroy)
    @cycle.destroy
    @center.destroy
    @program.destroy
  end

  def create_pitch_with_ratings
    create_seed_data
    @rating = create_list(:rating, 4,
                          panelist_id: @panelist[:id],
                          learners_pitch_id: @learners_pitch[:id])
  end

  def clear_pitch_with_ratings
    Rating.where(panelist_id: @panelist[:id]).destroy_all
    clear_seed_data
  end

  def create_new_pitch
    find("#new-pitch-btn").click
    find("#program-select-option").click
    find(".pitch-select-program", text: @program.name).click
    sleep 1
    find("#cycle-select-option").click
    sleep 1
    find(".pitch-select-cycle").click
    find("#next-btn").click
    fill_in("invite-panelist", with: "efe.love@andela.com")
    find(".add-invitee-icon ").click
    fill_in("invite-panelist", with: "ake.azem@andela.com").send_keys(:enter)
    find("#next-btn").click
    find("a.ui-datepicker-next").click
    find("a.ui-state-default", match: :first).click
    find(".submit-next").click
    visit("/pitch")
  end

  def test_learner_modal_contents
    expect(page).to have_css(".learners-rating-modal-content")
    expect(page).to have_css(".learner-dropdown")
    expect(page).to have_css(".learner-header-name")
    expect(page).to have_css(".learner-name")
    expect(page).to have_css(".learner-email")
  end

  def create_multiple_pitches(number)
    number.times do
      create_new_pitch
    end
  end
end
