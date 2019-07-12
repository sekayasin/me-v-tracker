module SurveyHelper
  def save_succeeds(survey, files = {})
    post :create, params: { **files, survey: survey.to_json },
                  headers: { "Content-Type": "multipart/form-data" }
    expect(response.body).to include("Successfully")
    expect(response.status).to eq(201)
  end

  def save_fails(survey, files = {})
    post :create, params: { **files, survey: survey.to_json },
                  headers: { "Content-Type": "multipart/form-data" }
    expect(response.status).to eq(400)
  end
end
