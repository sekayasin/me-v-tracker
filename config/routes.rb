Rails.application.routes.draw do

  resources :nps_ratings
  resources :nps_questions
  require 'sidekiq/web'
  require 'sidekiq/cron/web'

  mount Sidekiq::Web => '/sidekiq'

  root to: "select_dlc#index", as: "index"
  get "/login" => "sessions#login"
  get "/logout" => "sessions#logout"
  get "/sheet" => "index#sheet"
  get "/holistic-csv/:learner_program_id" => "holistic_evaluations#generate_learner_holistic_evaluation_report"
  get "/metrics/:assessment_id" => "assessments#get_assessment_metrics"

  post "/notifications" => "notifications#create"
  delete "/notifications" => "notifications#update"
  resources :index, path: "learners", except: [:show, :edit]
  resources :assessments
  resource :reflections, only: %i(show update create)

  scope "/learners", as: "bootcampers" do
    get "/" => "bootcampers#index"
    post "/add" => "bootcampers#add"
    post ":id/:learner_program_id/holistic-evaluations" => "holistic_evaluations#create"
    put ":learner_program_id/holistic-evaluations" => "holistic_evaluations#update"
    post ":id/:learner_program_id/holistic-feedback" => "holistic_feedback#create"

    get ":learner_program_id/evaluation-eligibility" => "holistic_evaluations#eligibility"

    get ":learner_program_id/holistic-average" => "holistic_evaluations#holistic_average"

    get ":learner_program_id/holistic-criteria-average" => "holistic_evaluations#holistic_criteria_averages"

    get ":program_id/holistic-criteria-info" => "holistic_evaluations#holistic_criteria_info"

    get ":learner_program_id/decision-history" => "decisions#get_history"
    get "/:id/:learner_program_id/scores" => "scores#new"
    post "/:id/:learner_program_id/scores/new" => "scores#create"
    get "/:id/:learner_program_id/get-learner-city" => "learners#get_learner_city"

    put "/:id/:learner_program_id/update-learner" => "learners#update_learner_information"

    get "/:id/:learner_program_id/completed_assessments" => "assessments#get_completed_assessments"

    put "/decision-status/:learner_program_id" => "bootcampers#update"
    put "/lfa-update/:learner_program_id" => "bootcampers#update"
    put "/personal_details/update" => "learners#update_learner_personal_details"
  end
  get "/centers/learners" => "bootcampers#get_learners"
  put "/update_learner_lfa" => "bootcampers#update_lfa"
  get "/centers" => "index#get_cities"
  get "/cycle" => "index#get_latest_cycle"
  get "analytics" => "dashboard#index"
  get "/analytics/export" => "dashboard#sheet"
  get "/phases/:id/assessment" => "assessments#all"
  get "support" => "support#index"
  get "curriculum" => "curricula#index"
  post "criteria" => "criteria#create"
  put "criteria/:id/description" => "criteria#update"
  delete "/criteria/:id" => "criteria#destroy"

  get "/decision/reason/:status" => "decisions#get_decision_reason"
  post "/decision/add" => "decisions#save_decision"

  get "/submissions" => "submissions#index"
  get "/submissions/learners" => "submissions#get_submissions"
  get "submissions/filter/cycles" => "submissions#get_cycles"
  get "submissions/filter/facilitators" => "submissions#get_facilitators"
  get "submissions/learner/:learner_program_id" => "submissions#get_learner_assessments_by_phases"
  get "submissions/:learner_program_id" => "submissions#get_learner_submissions", as: 'submission'
  get "submissions/:learner_program_id/:phaseId/:assessment_id" => "submissions#get_learner_output"
  get "submissions/:learner_program_id/:assessment_id" => "submissions#get_learner_output"
  get "download/:file_name_id" => "submissions#download_output"
  get "submission/filter" => "submissions#get_center_params"

  scope "surveys" do
    get "/" => "surveys#index"
    post "/" => "surveys#create"
    get "recipients" => "surveys#get_recipients"
    get "/:id/recipients" => "surveys#get_selected_recipients"
    put "/:id/update" => "surveys#update"
    put "/:id/close" => "surveys#close"
    delete "/:id/delete" => "surveys#destroy"
  end

  scope "surveys-v2", as: "surveys_v2" do
    get "/" => "surveys_v2#index"
    post "/" => "surveys_v2#create"
    get "/setup" => "surveys_v2#setup"
    get "/:survey_id/edit" => "surveys_v2#edit"
    put "/update" => "surveys_v2#update_survey"
    get "recipients" => "surveys_v2#get_recipients"
    get "/respond/:survey_id" => "surveys_v2#get_responses"
    post "/respond/:survey_id" => "surveys_v2_respond#create"
    get "/respond" => "surveys_v2#respond"
    get "/show/:id" => "surveys_v2#show"
    get "/respond/:survey_id/edit" => "surveys_v2_respond#edit"
    post "/clone" => "surveys_v2#clone_survey"
    delete "/:id" => "surveys_v2#destroy"
    get "/download" => "surveys_v2#download_file"
    get "/responses/:id" => "surveys_v2#survey_responses"
    get "/responses" => "surveys_v2#responses"
    post "/share-responses" => "surveys_v2#share_response"
    put "/toggle-archive" => "surveys_v2#toggle_archive"
	  get "/respondents" => "surveys_v2#get_respondents"
  end

  # Non Andelans / Learner route
  get "learner" => "learners#index"
  get "learner/ecosystem" => "learning_ecosystem#index"
  get "/learner/ecosystem/phases" => "learning_ecosystem#get_learner_ecosystem_phases"
  get "/learner/output/view" => "learning_ecosystem#get_learner_outputs"
  get "learner/get_learner_technical_details" => "learners#get_learner_technical_details"
  put "learner/update_learner_technical_details" => "learners#update_learner_technical_details"

  get "feedback" => "feedback#feedback_details"
  get "feedback/get-learner-feedback" => "feedback#get_learner_feedback"
  get "/feedback/:phase_id/:assessment_id" => "feedback#get_lfa_feedback"
  post "feedback/save" => "feedback#save_feedback"
  get "/phases/:phase_id/assessments" => "assessments#get_phase_assessments"
  post "/learner/program_feedback" => "program_nps#save_program_feedback"
  get "/program_feedback/details" => "program_nps#get_program_feedback_details"
  post "/schedule_feedback" => "schedule_feedback#save_feedback_schedule"

  get "/curriculum/details" => "curricula#get_curriculum_details"

  scope "programs" do
    get "/" => "programs#index"
    post "/" => "programs#create"
    put "/:program_id/update" => "programs#update"
    put "/:program_id/phases/:phase_id/assessments" => "programs#save_program_draft"
    get "/:id/edit" => "programs#edit"
    get "/:id/edit-details" => "programs#edit_details"
    get "/:program_id/dlc-stack" => "dlc_stack#show_program_dlc_stack"
    get "/:program_id/program-status" => "learner_programs#get_existing_program"
    get "/:program_id/program-metrics" => "dashboard#program_metrics"
    get "/:program_id/centers/:center/cycles" => "dashboard#cycle_center_metrics"
    get "/:program_id/centers/:center/cycles/:cycle/program-feedback" => "dashboard#program_feedback"
    get "/:program_id/feedback-centers" => "dashboard#program_feedback_centers"
    get "/:program_id/assessments" => "programs#get_program_assessments"
    get "/:program_id/phase/:phase" => "dashboard#program_health_metrics"
    get "/:id" => "programs#get_program", as: "get_program"
    get "/:size/:page" => "programs#index"
  end

  scope "tours" do
    get "/:page" => "tours#user_status"
    post "/:page" => "tours#create"
  end

  scope "pitch" do
    get "/"      => "pitch#index"
    get "/setup" => "pitch#pitch_setup"
    get "/setup/:cycle_center_id" => "pitch#get_learners_cycle"
    get "/program/:program_id" => "pitch#get_program_cycle"
    get "/:pitch_id"   => "pitch#show"
    get "/show/:learners_pitch_id" => "pitch#show_learner_ratings"
    put "/:pitch_id" => "pitch#update"
    get "/:pitch_id/edit" => "pitch#edit"
    get "/:pitch_id/ratings/:learner_id" => "pitch#get_rating_breakdown"
    post "/" => "pitch#create"
    get "/:pitch_id/:learner_id" => "pitch#rate_learners"
    delete "/:pitch_id" => "pitch#destroy"
    post "/submit_learner_ratings" => "pitch#submit_learner_ratings"
  end

  post "/output/submit" => "assessments#submit_assessment_output"

  put "/output/update" => "assessments#update_assessment_output"

  get "/output/details" => "assessments#get_framework_criteria"

  get "/framework/:id/criteria" => "criteria#get_criteria"

  put "/framework/:id/description" => "frameworks#update"

  get "/framework-criteria/:framework_id/:criterium_id" => "criteria#get_framework_criterium_id"

  get "/cadences" => "cadences#index"

  get "/admins" => "admins#index"

  get "/assessments/submissions/:id" => "assessments#fetch_submission_phases"

  get "not_found" => "no_access#index", as: "not_found"

  # dedicated healthcheck route
  get '/health', to: proc { [200, {}, ['']] }

  match "/(*url)", to: "no_access#index", via: :all

end
