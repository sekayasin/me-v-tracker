class SupportController < ApplicationController
  skip_before_action :redirect_non_andelan

  def index
    support = SupportService.new
    support_data = support.get_support_data
    user_type = helpers.authorized_learner? ? "learner" : "user"
    @faqs = support_data["faqs"][user_type]
    @resources = support_data["resources"][user_type]
    @faqs = search if params[:search]
  end

  private

  def search
    answers_check = support_data_search(@faqs, "answer")
    questions_check = support_data_search(@faqs, "question")
    questions_check.concat(answers_check).uniq
  end

  def support_data_search(category, section)
    normalized_search_term = params[:search].downcase
    category.select do |item|
      item[section].downcase.include? normalized_search_term
    end
  end
end
