module HolisticEvaluationHelper
  def go_to_profile_page
    stub_andelan
    stub_current_session
    visit("/")
    find("a.dropdown-input").click
    find("ul#index-dropdown li a.dropdown-link").click
    find("img.proceed-btn").click
    click_on "Learners"

    first_name = @bootcamper.first_name
    last_name = @bootcamper.last_name
    camper_name = "#{first_name} #{last_name}"

    find("a", text: camper_name).click
    sleep 2
  end

  def submit_holistic_evaluation
    find("a.evaluation-select").click
    find(".holistic-evaluation-btn").click

    sleep 1

    score_nodes = find_all(
      ".select-background>span"
    )

    score_nodes.each do |node|
      node.click
      find("li.ui-menu-item", text: "Unsatisfied (-1)").click
    end

    comment_nodes = find_all("div.comment-area textarea.leave-comment")
    comment_nodes.each do |node|
      node.set("More work")
    end

    find("#confirm-submission").click
    find("#confirm-evaluation-submission").click
  end

  def expect_limit_warning
    find("a.evaluation-select").click
    find(".holistic-evaluation-btn").click

    within("#evaluation-limit-modal") do
      modal_header = find(".confirmation-header")
      expect(modal_header).to have_content("Submission Warning")

      warning = find("p.warning-text")
      expect(warning).to have_content(
        "Evaluations for this learner have been completed successfully, " \
        "close this modal to view or edit the scores."
      )

      find("span.close-button").click
    end
  end

  def expect_disabled_modal
    within("#holistic-performance-evaluation") do
      submit_button = find("#confirm-submission")
      comment_nodes = find_all("div.comment-area textarea.leave-comment")
      score_nodes = find_all(
        ".select-background>span"
      )

      expect(submit_button[:class]).to include("disabled")

      comment_nodes.each do |node|
        expect(node[:class]).to include("disabled")
      end

      score_nodes.each do |node|
        expect(node[:class]).to include("disabled")
      end
    end
  end
end
