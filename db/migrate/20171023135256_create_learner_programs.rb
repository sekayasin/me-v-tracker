class CreateLearnerPrograms < ActiveRecord::Migration[5.0]
  def change
    create_table :learner_programs do |t|
      t.string   "week_one_lfa"
      t.datetime "created_at",                           null: false
      t.datetime "updated_at",                           null: false
      t.string   "week_two_lfa"
      t.string   "decision_one"
      t.string   "cycle"
      t.string   "email"
      t.string   "city"
      t.string   "country"
      t.string   "decision_two"
      t.integer  "progress_week1"
      t.integer  "progress_week2"
      t.decimal  "overall_average",      default: "0.0"
      t.decimal  "week1_average",        default: "0.0"
      t.decimal  "week2_average",        default: "0.0"
      t.decimal  "project_average",      default: "0.0"
      t.decimal  "value_average",        default: "0.0"
      t.decimal  "output_average",       default: "0.0"
      t.decimal  "feedback_average",     default: "0.0"
      t.text     "decision_one_comment"
      t.text     "decision_two_comment"
      t.string   "camper_id"
      t.string   "program_id"
      t.timestamps

      t.references :program, foreign_key: true
    end

    add_foreign_key :learner_programs, :bootcampers, column: :camper_id, primary_key: :camper_id

    add_column :scores, :learner_programs_id, :integer
    add_foreign_key :scores, :learner_programs, column: :learner_programs_id, primary_key: :id

    add_column :bootcamper_decision_reasons, :learner_programs_id, :integer
    add_foreign_key :bootcamper_decision_reasons, :learner_programs, column: :learner_programs_id, primary_key: :id

  end
end
