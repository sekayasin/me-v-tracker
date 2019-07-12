# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190725145219) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"

  create_table "assessment_output_submissions", force: :cascade do |t|
    t.integer  "position"
    t.string   "title"
    t.integer  "day"
    t.string   "file_type"
    t.integer  "assessment_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "phase_id"
    t.index ["assessment_id"], name: "index_assessment_output_submissions_on_assessment_id", using: :btree
  end

  create_table "assessments", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.text     "context"
    t.integer  "framework_criterium_id"
    t.text     "description"
    t.text     "expectation"
    t.boolean  "requires_submission",    default: false
    t.datetime "deleted_at"
    t.string   "submission_types"
    t.index ["deleted_at"], name: "index_assessments_on_deleted_at", using: :btree
    t.index ["framework_criterium_id"], name: "index_assessments_on_framework_criterium_id", using: :btree
  end

  create_table "assessments_criteria", force: :cascade do |t|
    t.integer "assessment_id"
    t.integer "criterium_id"
    t.index ["assessment_id"], name: "index_assessments_criteria_on_assessment_id", using: :btree
    t.index ["criterium_id"], name: "index_assessments_criteria_on_criterium_id", using: :btree
  end

  create_table "assessments_phases", force: :cascade do |t|
    t.integer "assessment_id"
    t.integer "phase_id"
    t.index ["assessment_id", "phase_id"], name: "index_assessments_phases_on_assessment_id_and_phase_id", unique: true, using: :btree
    t.index ["assessment_id"], name: "index_assessments_phases_on_assessment_id", using: :btree
    t.index ["phase_id"], name: "index_assessments_phases_on_phase_id", using: :btree
  end

  create_table "bootcampers", primary_key: "camper_id", id: :string, force: :cascade do |t|
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "gender"
    t.string   "phone_number"
    t.text     "about"
    t.datetime "last_seen_at"
    t.integer  "proficiency_id"
    t.string   "trello"
    t.string   "github"
    t.string   "linkedin"
    t.string   "website"
    t.string   "uuid"
    t.string   "greenhouse_candidate_id"
    t.string   "middle_name"
    t.string   "avatar"
    t.string   "username"
    t.index ["camper_id"], name: "index_bootcampers_on_camper_id", unique: true, using: :btree
    t.index ["proficiency_id"], name: "index_bootcampers_on_proficiency_id", using: :btree
  end

  create_table "bootcampers_cycles_centers", id: false, force: :cascade do |t|
    t.string   "bcc_id"
    t.string   "camper_id"
    t.string   "cycle_center_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["bcc_id"], name: "index_bootcampers_cycles_centers_on_bcc_id", using: :btree
  end

  create_table "bootcampers_language_stacks", id: false, force: :cascade do |t|
    t.string  "camper_id"
    t.integer "language_stack_id"
    t.index ["camper_id"], name: "index_bootcampers_language_stacks_on_camper_id", using: :btree
    t.index ["language_stack_id"], name: "index_bootcampers_language_stacks_on_language_stack_id", using: :btree
  end

  create_table "cadences", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "days"
  end

  create_table "centers", id: false, force: :cascade do |t|
    t.string   "center_id"
    t.string   "name"
    t.string   "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["center_id"], name: "index_centers_on_center_id", using: :btree
  end

  create_table "collaborators", force: :cascade do |t|
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "criteria", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.boolean  "belongs_to_dev_framework", default: false
    t.string   "context"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_criteria_on_deleted_at", using: :btree
  end

  create_table "cycle_centers_new_surveys", force: :cascade do |t|
    t.integer "new_survey_id"
    t.string  "cycle_center_id"
    t.index ["cycle_center_id"], name: "index_cycle_centers_new_surveys_on_cycle_center_id", using: :btree
    t.index ["new_survey_id"], name: "index_cycle_centers_new_surveys_on_new_survey_id", using: :btree
  end

  create_table "cycles", id: false, force: :cascade do |t|
    t.integer  "cycle"
    t.string   "cycle_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cycle_id"], name: "index_cycles_on_cycle_id", using: :btree
  end

  create_table "cycles_centers", id: false, force: :cascade do |t|
    t.string   "cycle_center_id"
    t.string   "center_id"
    t.string   "cycle_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "program_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["cycle_center_id"], name: "index_cycles_centers_on_cycle_center_id", unique: true, using: :btree
    t.index ["program_id"], name: "index_cycles_centers_on_program_id", using: :btree
  end

  create_table "decision_reason_statuses", id: false, force: :cascade do |t|
    t.integer "decision_reason_id"
    t.integer "decision_status_id"
    t.index ["decision_reason_id"], name: "index_decision_reason_statuses_on_decision_reason_id", using: :btree
    t.index ["decision_status_id"], name: "index_decision_reason_statuses_on_decision_status_id", using: :btree
  end

  create_table "decision_reasons", force: :cascade do |t|
    t.string "reason"
  end

  create_table "decision_statuses", force: :cascade do |t|
    t.string "status"
  end

  create_table "decisions", force: :cascade do |t|
    t.integer  "decision_stage"
    t.integer  "decision_reason_id"
    t.integer  "learner_programs_id"
    t.text     "comment"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "dlc_stacks", force: :cascade do |t|
    t.integer  "program_id"
    t.integer  "language_stack_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["language_stack_id"], name: "index_dlc_stacks_on_language_stack_id", using: :btree
    t.index ["program_id"], name: "index_dlc_stacks_on_program_id", using: :btree
  end

  create_table "evaluation_averages", force: :cascade do |t|
    t.float    "holistic_average"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.decimal  "dev_framework_average"
  end

  create_table "facilitators", id: :string, force: :cascade do |t|
    t.string   "email",      null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_facilitators_on_email", unique: true, using: :btree
  end

  create_table "feedback", force: :cascade do |t|
    t.integer  "learner_program_id"
    t.integer  "phase_id"
    t.integer  "assessment_id"
    t.integer  "impression_id"
    t.text     "comment"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "finalized",             default: false
    t.integer  "output_submissions_id"
    t.index ["assessment_id"], name: "index_feedback_on_assessment_id", using: :btree
    t.index ["impression_id"], name: "index_feedback_on_impression_id", using: :btree
    t.index ["learner_program_id"], name: "index_feedback_on_learner_program_id", using: :btree
    t.index ["phase_id"], name: "index_feedback_on_phase_id", using: :btree
  end

  create_table "framework_criteria", force: :cascade do |t|
    t.integer  "criterium_id"
    t.integer  "framework_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["criterium_id"], name: "index_framework_criteria_on_criterium_id", using: :btree
    t.index ["framework_id"], name: "index_framework_criteria_on_framework_id", using: :btree
  end

  create_table "frameworks", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.text     "description"
  end

  create_table "holistic_evaluations", force: :cascade do |t|
    t.integer  "score"
    t.text     "comment"
    t.integer  "learner_program_id"
    t.integer  "criterium_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "evaluation_average_id"
    t.index ["criterium_id"], name: "index_holistic_evaluations_on_criterium_id", using: :btree
    t.index ["evaluation_average_id"], name: "index_holistic_evaluations_on_evaluation_average_id", using: :btree
    t.index ["learner_program_id"], name: "index_holistic_evaluations_on_learner_program_id", using: :btree
  end

  create_table "holistic_feedback", force: :cascade do |t|
    t.text     "comment"
    t.integer  "learner_program_id"
    t.integer  "criterium_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["criterium_id"], name: "index_holistic_feedback_on_criterium_id", using: :btree
    t.index ["learner_program_id"], name: "index_holistic_feedback_on_learner_program_id", using: :btree
  end

  create_table "impressions", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "language_stacks", force: :cascade do |t|
    t.string   "name"
    t.boolean  "dlc_stack_status"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "learner_programs", force: :cascade do |t|
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "decision_one",            default: "In Progress"
    t.string   "decision_two"
    t.integer  "progress"
    t.decimal  "overall_average",         default: "0.0"
    t.decimal  "value_average",           default: "0.0"
    t.decimal  "output_average",          default: "0.0"
    t.decimal  "feedback_average",        default: "0.0"
    t.string   "camper_id"
    t.integer  "program_id"
    t.integer  "dlc_stack_id"
    t.integer  "proficiency_id"
    t.string   "program_year_id"
    t.string   "cycle_center_id"
    t.string   "week_one_facilitator_id"
    t.string   "week_two_facilitator_id"
    t.index ["program_id"], name: "index_learner_programs_on_program_id", using: :btree
    t.index ["program_year_id"], name: "index_learner_programs_on_program_year_id", using: :btree
  end

  create_table "learners_pitches", force: :cascade do |t|
    t.integer  "pitch_id"
    t.string   "camper_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pitch_id"], name: "index_learners_pitches_on_pitch_id", using: :btree
  end

  create_table "metrics", force: :cascade do |t|
    t.text    "description"
    t.integer "point_id"
    t.integer "assessment_id"
    t.integer "criteria_id"
    t.index ["assessment_id"], name: "index_metrics_on_assessment_id", using: :btree
    t.index ["criteria_id"], name: "index_metrics_on_criteria_id", using: :btree
    t.index ["point_id", "assessment_id"], name: "index_metrics_on_point_id_and_assessment_id", unique: true, using: :btree
    t.index ["point_id"], name: "index_metrics_on_point_id", using: :btree
  end

  create_table "new_survey_collaborators", force: :cascade do |t|
    t.integer  "new_survey_id"
    t.integer  "collaborator_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["collaborator_id"], name: "index_new_survey_collaborators_on_collaborator_id", using: :btree
    t.index ["new_survey_id"], name: "index_new_survey_collaborators_on_new_survey_id", using: :btree
  end

  create_table "new_surveys", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.string   "status"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean  "edit_response"
    t.integer  "survey_responses_count"
    t.text     "survey_creator"
  end

  create_table "notification_groups", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.string   "recipient_email"
    t.integer  "notifications_message_id"
    t.boolean  "is_read"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["notifications_message_id"], name: "index_notifications_on_notifications_message_id", using: :btree
  end

  create_table "notifications_messages", force: :cascade do |t|
    t.string   "content"
    t.string   "priority"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "notification_group_id"
    t.index ["notification_group_id"], name: "index_notifications_messages_on_notification_group_id", using: :btree
  end

  create_table "nps_questions", id: false, force: :cascade do |t|
    t.string   "nps_question_id"
    t.text     "question"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.text     "title"
    t.text     "description"
    t.index ["nps_question_id"], name: "index_nps_questions_on_nps_question_id", using: :btree
  end

  create_table "nps_ratings", id: false, force: :cascade do |t|
    t.string   "nps_ratings_id"
    t.integer  "rating"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["nps_ratings_id"], name: "index_nps_ratings_on_nps_ratings_id", using: :btree
  end

  create_table "nps_responses", id: false, force: :cascade do |t|
    t.string   "nps_response_id"
    t.string   "nps_ratings_id"
    t.string   "nps_question_id"
    t.string   "cycle_center_id"
    t.text     "comment"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "learner_program_id"
    t.string   "camper_id"
    t.index ["camper_id"], name: "index_nps_responses_on_camper_id", using: :btree
    t.index ["learner_program_id"], name: "index_nps_responses_on_learner_program_id", using: :btree
    t.index ["nps_response_id"], name: "index_nps_responses_on_nps_response_id", using: :btree
  end

  create_table "output_submissions", force: :cascade do |t|
    t.string   "link"
    t.integer  "assessment_id"
    t.integer  "phase_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "learner_programs_id"
    t.text     "description"
    t.text     "file_link"
    t.text     "file_name"
    t.integer  "submission_phase_id"
    t.index ["assessment_id"], name: "index_output_submissions_on_assessment_id", using: :btree
    t.index ["phase_id"], name: "index_output_submissions_on_phase_id", using: :btree
  end

  create_table "panelists", force: :cascade do |t|
    t.integer  "pitch_id"
    t.string   "email"
    t.string   "accepted",   default: "f"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "visited",    default: false, null: false
    t.index ["pitch_id"], name: "index_panelists_on_pitch_id", using: :btree
  end

  create_table "phases", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "phase_duration"
    t.boolean  "phase_decision_bridge", default: false
    t.index ["name"], name: "index_phases_on_name", using: :btree
  end

  create_table "pitches", force: :cascade do |t|
    t.string   "cycle_center_id"
    t.date     "demo_date"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "created_by"
  end

  create_table "points", force: :cascade do |t|
    t.integer "value"
    t.string  "context"
  end

  create_table "proficiencies", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "program_years", primary_key: "program_year_id", id: :string, force: :cascade do |t|
    t.string   "year_id"
    t.string   "target_id"
    t.integer  "program_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["program_id"], name: "index_program_years_on_program_id", using: :btree
    t.index ["program_year_id"], name: "index_program_years_on_program_year_id", using: :btree
  end

  create_table "programs", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "estimated_duration",  default: 0
    t.boolean  "save_status",         default: false
    t.boolean  "holistic_evaluation"
    t.integer  "cadence_id"
    t.index ["cadence_id"], name: "index_programs_on_cadence_id", using: :btree
  end

  create_table "programs_phases", force: :cascade do |t|
    t.integer  "program_id"
    t.integer  "phase_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "position"
    t.index ["phase_id"], name: "index_programs_phases_on_phase_id", using: :btree
    t.index ["program_id"], name: "index_programs_phases_on_program_id", using: :btree
  end

  create_table "ratings", force: :cascade do |t|
    t.integer  "learners_pitch_id"
    t.integer  "panelist_id"
    t.integer  "ui_ux"
    t.integer  "api_functionality"
    t.integer  "error_handling"
    t.integer  "project_understanding"
    t.integer  "presentational_skill"
    t.string   "decision"
    t.text     "comment"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["learners_pitch_id"], name: "index_ratings_on_learners_pitch_id", using: :btree
    t.index ["panelist_id"], name: "index_ratings_on_panelist_id", using: :btree
  end

  create_table "reflections", force: :cascade do |t|
    t.string   "comment"
    t.integer  "feedback_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "schedule_feedbacks", force: :cascade do |t|
    t.string   "cycle_center_id"
    t.string   "nps_question_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "program_id"
  end

  create_table "scores", force: :cascade do |t|
    t.float    "score"
    t.string   "week"
    t.text     "comments"
    t.integer  "assessment_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "phase_id"
    t.integer  "learner_programs_id"
    t.index ["assessment_id"], name: "index_scores_on_assessment_id", using: :btree
    t.index ["phase_id"], name: "index_scores_on_phase_id", using: :btree
  end

  create_table "survey_date_questions", force: :cascade do |t|
    t.date     "min"
    t.date     "max"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "survey_date_responses", force: :cascade do |t|
    t.string   "question_type"
    t.date     "value"
    t.integer  "question_id"
    t.integer  "survey_response_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["survey_response_id"], name: "index_survey_date_responses_on_survey_response_id", using: :btree
  end

  create_table "survey_grid_option_responses", force: :cascade do |t|
    t.string   "question_type"
    t.integer  "row_id"
    t.integer  "col_id"
    t.integer  "question_id"
    t.integer  "survey_response_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["survey_response_id"], name: "index_survey_grid_option_responses_on_survey_response_id", using: :btree
  end

  create_table "survey_option_questions", force: :cascade do |t|
    t.string   "question_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "survey_option_responses", force: :cascade do |t|
    t.string   "question_type"
    t.integer  "option_id"
    t.integer  "question_id"
    t.integer  "survey_response_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["survey_response_id"], name: "index_survey_option_responses_on_survey_response_id", using: :btree
  end

  create_table "survey_options", force: :cascade do |t|
    t.text     "option"
    t.string   "option_type"
    t.integer  "position"
    t.integer  "survey_option_question_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["survey_option_question_id"], name: "index_survey_options_on_survey_option_question_id", using: :btree
  end

  create_table "survey_paragraph_questions", force: :cascade do |t|
    t.integer  "max_length"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "survey_paragraph_responses", force: :cascade do |t|
    t.string   "question_type"
    t.text     "value"
    t.integer  "question_id"
    t.integer  "survey_response_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["survey_response_id"], name: "index_survey_paragraph_responses_on_survey_response_id", using: :btree
  end

  create_table "survey_questions", force: :cascade do |t|
    t.text     "question"
    t.text     "description"
    t.string   "description_type"
    t.integer  "position"
    t.boolean  "is_required"
    t.string   "questionable_type"
    t.integer  "questionable_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "survey_section_id"
    t.index ["questionable_type", "questionable_id"], name: "index_survey_questions_on_questionable_type_and_questionable_id", using: :btree
    t.index ["survey_section_id"], name: "index_survey_questions_on_survey_section_id", using: :btree
  end

  create_table "survey_responses", force: :cascade do |t|
    t.string   "respondable_id"
    t.string   "respondable_type"
    t.integer  "new_survey_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["new_survey_id"], name: "index_survey_responses_on_new_survey_id", using: :btree
  end

  create_table "survey_scale_questions", force: :cascade do |t|
    t.integer  "min"
    t.integer  "max"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "survey_scale_responses", force: :cascade do |t|
    t.string   "question_type"
    t.integer  "value"
    t.integer  "question_id"
    t.integer  "survey_response_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["survey_response_id"], name: "index_survey_scale_responses_on_survey_response_id", using: :btree
  end

  create_table "survey_section_rules", force: :cascade do |t|
    t.integer  "survey_section_id"
    t.integer  "survey_option_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["survey_option_id"], name: "index_survey_section_rules_on_survey_option_id", using: :btree
    t.index ["survey_section_id"], name: "index_survey_section_rules_on_survey_section_id", using: :btree
  end

  create_table "survey_sections", force: :cascade do |t|
    t.string   "position"
    t.integer  "new_survey_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["new_survey_id"], name: "index_survey_sections_on_new_survey_id", using: :btree
  end

  create_table "survey_time_questions", force: :cascade do |t|
    t.time     "min"
    t.time     "max"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "survey_time_responses", force: :cascade do |t|
    t.string   "question_type"
    t.time     "value"
    t.integer  "question_id"
    t.integer  "survey_response_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["survey_response_id"], name: "index_survey_time_responses_on_survey_response_id", using: :btree
  end

  create_table "surveys", id: false, force: :cascade do |t|
    t.string   "survey_id"
    t.string   "title"
    t.string   "link"
    t.string   "status",     default: "Receiving Feedback"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.index ["survey_id"], name: "index_surveys_on_survey_id", using: :btree
  end

  create_table "surveys_pivots", force: :cascade do |t|
    t.string "survey_id"
    t.string "surveyable_id"
    t.string "surveyable_type"
    t.index ["surveyable_type", "surveyable_id"], name: "index_surveys_pivots_on_surveyable_type_and_surveyable_id", using: :btree
  end

  create_table "targets", primary_key: "target_id", id: :string, force: :cascade do |t|
    t.decimal "performance_target", default: "0.0"
    t.decimal "output_target",      default: "0.0"
  end

  create_table "tourist_tours", force: :cascade do |t|
    t.string   "tourist_email"
    t.integer  "tour_id"
    t.text     "role"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["tour_id"], name: "index_tourist_tours_on_tour_id", using: :btree
  end

  create_table "tourists", primary_key: "tourist_email", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tours", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "years", primary_key: "year_id", id: :string, force: :cascade do |t|
    t.string   "year",       default: "2018"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_foreign_key "assessments", "framework_criteria"
  add_foreign_key "bootcampers", "proficiencies"
  add_foreign_key "bootcampers_language_stacks", "bootcampers", column: "camper_id", primary_key: "camper_id"
  add_foreign_key "bootcampers_language_stacks", "language_stacks"
  add_foreign_key "cycles_centers", "programs"
  add_foreign_key "decisions", "decision_reasons"
  add_foreign_key "decisions", "learner_programs", column: "learner_programs_id"
  add_foreign_key "dlc_stacks", "language_stacks"
  add_foreign_key "dlc_stacks", "programs", on_delete: :cascade
  add_foreign_key "feedback", "assessments"
  add_foreign_key "feedback", "impressions"
  add_foreign_key "feedback", "learner_programs"
  add_foreign_key "feedback", "phases"
  add_foreign_key "framework_criteria", "criteria"
  add_foreign_key "framework_criteria", "frameworks"
  add_foreign_key "holistic_evaluations", "criteria"
  add_foreign_key "holistic_evaluations", "evaluation_averages"
  add_foreign_key "holistic_evaluations", "learner_programs"
  add_foreign_key "holistic_feedback", "criteria"
  add_foreign_key "holistic_feedback", "learner_programs"
  add_foreign_key "learner_programs", "bootcampers", column: "camper_id", primary_key: "camper_id"
  add_foreign_key "learner_programs", "dlc_stacks"
  add_foreign_key "learner_programs", "facilitators", column: "week_one_facilitator_id"
  add_foreign_key "learner_programs", "facilitators", column: "week_two_facilitator_id"
  add_foreign_key "learner_programs", "proficiencies"
  add_foreign_key "learner_programs", "program_years", primary_key: "program_year_id"
  add_foreign_key "learner_programs", "programs", on_delete: :cascade
  add_foreign_key "learners_pitches", "bootcampers", column: "camper_id", primary_key: "camper_id"
  add_foreign_key "learners_pitches", "pitches"
  add_foreign_key "metrics", "assessments"
  add_foreign_key "metrics", "criteria", column: "criteria_id"
  add_foreign_key "metrics", "points"
  add_foreign_key "new_survey_collaborators", "collaborators"
  add_foreign_key "new_survey_collaborators", "new_surveys"
  add_foreign_key "notifications", "notifications_messages"
  add_foreign_key "notifications_messages", "notification_groups"
  add_foreign_key "output_submissions", "assessments"
  add_foreign_key "output_submissions", "learner_programs", column: "learner_programs_id"
  add_foreign_key "output_submissions", "phases"
  add_foreign_key "panelists", "pitches"
  add_foreign_key "pitches", "cycles_centers", column: "cycle_center_id", primary_key: "cycle_center_id"
  add_foreign_key "program_years", "programs"
  add_foreign_key "program_years", "targets", primary_key: "target_id"
  add_foreign_key "program_years", "years", primary_key: "year_id"
  add_foreign_key "programs", "cadences"
  add_foreign_key "programs_phases", "phases"
  add_foreign_key "programs_phases", "programs"
  add_foreign_key "ratings", "learners_pitches"
  add_foreign_key "ratings", "panelists"
  add_foreign_key "reflections", "feedback"
  add_foreign_key "scores", "assessments"
  add_foreign_key "scores", "learner_programs", column: "learner_programs_id"
  add_foreign_key "survey_date_responses", "survey_responses"
  add_foreign_key "survey_grid_option_responses", "survey_responses"
  add_foreign_key "survey_option_responses", "survey_responses"
  add_foreign_key "survey_options", "survey_option_questions"
  add_foreign_key "survey_paragraph_responses", "survey_responses"
  add_foreign_key "survey_questions", "survey_sections"
  add_foreign_key "survey_responses", "new_surveys"
  add_foreign_key "survey_scale_responses", "survey_responses"
  add_foreign_key "survey_section_rules", "survey_options"
  add_foreign_key "survey_section_rules", "survey_sections"
  add_foreign_key "survey_sections", "new_surveys"
  add_foreign_key "survey_time_responses", "survey_responses"
  add_foreign_key "tourist_tours", "tours"

  create_view "average_ratings", sql_definition: <<-SQL
      SELECT ratings.learners_pitch_id,
      learners_pitches.pitch_id,
      learners_pitches.camper_id,
      bootcampers.first_name,
      bootcampers.last_name,
      avg(ratings.ui_ux) AS avg_ui_ux,
      avg(ratings.api_functionality) AS avg_api_functionality,
      avg(ratings.error_handling) AS avg_error_handling,
      avg(ratings.project_understanding) AS avg_project_understanding,
      avg(ratings.presentational_skill) AS avg_presentational_skill,
      (avg(((((ratings.ui_ux + ratings.api_functionality) + ratings.error_handling) + ratings.project_understanding) + ratings.presentational_skill)) / 5.0) AS cumulative_average
     FROM ((ratings
       JOIN learners_pitches ON ((ratings.learners_pitch_id = learners_pitches.id)))
       JOIN bootcampers ON (((learners_pitches.camper_id)::text = (bootcampers.camper_id)::text)))
    GROUP BY ratings.learners_pitch_id, learners_pitches.camper_id, bootcampers.first_name, bootcampers.last_name, learners_pitches.pitch_id;
  SQL
end
