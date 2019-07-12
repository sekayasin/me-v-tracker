def no_status_helper
  let(:survey) do
    build(:new_survey, :no_status)
  end
end

def published_helper
  let(:survey) do
    build(:new_survey, :published)
  end
end

def draft_helper
  let(:survey) do
    build(:new_survey, :draft)
  end
end

def no_title_helper
  let(:survey) do
    build(:new_survey, :no_title)
  end
end

def wrong_status_helper
  let(:survey) do
    build(:new_survey, :wrong_status)
  end
end

def valid_survey_helper(survey)
  expect(survey.valid?).to eq(true)
  expect(survey.save).to eq(true)
end

def invalid_survey_helper(survey)
  expect(survey.valid?).to eq(false)
  expect(survey.save).to eq(false)
end
