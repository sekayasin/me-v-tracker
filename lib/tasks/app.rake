# rubocop:disable Metrics/BlockLength
namespace :app do
  desc "Calculates and updates the Bootcampers' averages"
  task compute_averages: :environment do
    Bootcamper.all.each do |camper|
      framework_averages = Score.framework_averages(camper.id)
      averages = {
        overall_average: Score.overall_average(camper.id),
        week1_average: Score.week_one_average(camper.id),
        week2_average: Score.week_two_average(camper.id),
        project_average: Score.final_project_average(camper.id),
        value_average: framework_averages[0],
        output_average: framework_averages[1],
        feedback_average: framework_averages[2]
      }
      camper.update(averages)
    end
    puts "Bootcampers' averages has been updated successfully"
  end

  desc "Updates assessment names"
  task update_assessment_names: :environment do
    code_assessment_name = "Code Syntax Norms"
    code_assessment = Assessment.find_by_name("Code Syntax Norms (PEP8/Airbnb)")
    code_assessment.update_attribute("name", code_assessment_name)

    project_assessment_name = "Project Management"
    project_assessment = Assessment.find_by_name("Trello/ Project Management")
    project_assessment.update_attribute("name", project_assessment_name)
  end

  desc "Convert lfas name to email"
  task convert_lfa_name_to_email: :environment do
    def convert_name_to_email(name)
      if name.blank?
        name = "Unassigned"
      end
      unless name.to_s.include?("@andela.com")
        name = name.downcase.tr(" ", ".").gsub(/[^\w@\.]/, "") << "@andela.com"
      end
      name
    end

    LearnerProgram.all.each do |program|
      program.update_attributes(
        week_one_lfa: convert_name_to_email(program.week_one_lfa),
        week_two_lfa: convert_name_to_email(program.week_two_lfa)
      )
    end
    puts "[*] Updated learner program with lfa emails"
  end

  desc "Add references to programs"
  task add_references_to_programs: :environment do
    program = Program.first

    Bootcamper.all.each do |bootcamper|
      bootcamper.update_attribute("program_id", program.id)
    end
  end

  desc "Add estimated duration to programs"
  task add_estimated_duration_to_programs: :environment do
    Program.all.each do |program|
      program.update_attribute("estimated_duration", "2 Weeks")
    end
  end

  desc "Convert Bootcamp Program name to Bootcamp v1"
  task convert_to_bootcamp_v1: :environment do
    bootcamp_program_name = "Bootcamp v1"
    bootcamp_program = Program.find_by_name("Bootcamp")
    bootcamp_program.update_attribute("name", bootcamp_program_name)
  end

  desc "Update Bootcamp v1 save_status to true"
  task update_bootcamp_v1_save_status: :environment do
    bootcamp_save_status = "true"
    bootcamp_program = Program.find_by_name("Bootcamp v1")
    bootcamp_program.update_attribute("save_status", bootcamp_save_status)
  end

  desc "Update framework_criterium_id for assessments"
  task update_assessment_criteria: :environment do
    scoring_guide = ScoringGuideService.new

    FrameworkCriterium.all.each do |framework_criterium|
      populate_assessment(
        framework_criterium.id,
        scoring_guide.get_assessments(
          framework_criterium.criterium.name,
          framework_criterium.framework.name
        )
      )
    end
  end

  def populate_assessment(framework_criterium_id, assessments)
    assessments&.each do |assessment|
      assessment_instance = Assessment.find_by_name(assessment)
      assessment_instance.update(
        framework_criterium_id: framework_criterium_id
      )
    end
  end

  def add_score_foreign_key
    Score.all.each do |score|
      learner_program = LearnerProgram.find_by(camper_id: score.camper_id)
      score.update_attribute("learner_programs_id", learner_program.id)
    end
  end

  def add_bootcamper_decision_foreign_key
    Decision.all.each do |decision|
      learner_program = LearnerProgram.find_by(camper_id: decision.camper_id)
      decision.update_attribute("learner_programs_id", learner_program.id)
    end
  end

  def bootcamper_list
    Bootcamper.select(
      "week_one_lfa", "week_two_lfa", "decision_one",
      "created_at", "updated_at", "cycle",
      "email", "city", "country", "decision_two",
      "progress_week1", "progress_week2", "overall_average",
      "week1_average", "week2_average", "project_average",
      "value_average", "output_average", "feedback_average",
      "decision_one_comment", "decision_two_comment", "camper_id",
      "program_id"
    ).all
  end

  desc "Move Records from Bootcamper to Learner Program Table"
  task move_record_to_learner_program: :environment do
    bootcamper = bootcamper_list
    LearnerProgram.create(bootcamper.as_json)
    add_score_foreign_key
    add_bootcamper_decision_foreign_key
  end

  desc "Add Decision Bridge and Phase Duration for the Bootcamp v1"
  task add_decision_bridge_and_phase_duration: :environment do
    program = Program.first
    program.update_attribute("estimated_duration", 10)
    program.phases.each do |phase|
      if phase.name == "Home Session 4"
        phase.update_attributes(phase_decision_bridge: false, phase_duration: 0)
      elsif phase.name == "One Day Onsite"
        phase.update_attributes(phase_decision_bridge: true, phase_duration: 1)
      elsif phase.name == "Project Assessment"
        phase.update_attributes(phase_decision_bridge: true, phase_duration: 0)
      elsif phase.name == "Bootcamp"
        phase.update_attributes(phase_decision_bridge: false, phase_duration: 5)
      else
        phase.update_attributes(phase_decision_bridge: false, phase_duration: 1)
      end
    end
  end

  desc "Populate bootcampers' UUID in the database"
  task populate_uuid_for_bootcampers: :environment do
    learners_in_csv = load_bootcampers_uuid
    learners_in_csv.each do |learner_row|
      next if learner_row.nil?

      learner_row = learner_row.to_s.split("\t")
      learner_name = learner_row[3].split(" ")
      bootcamper = Bootcamper.includes(:learner_programs).
                   find_by(
                     first_name: learner_name,
                     last_name: learner_name,
                     learner_programs: {
                       decision_two: "Accepted",
                       city: learner_row[1]
                     }
                   )
      next if bootcamper.nil?

      if bootcamper.gender.nil?
        bootcamper.update(uuid: learner_row[5].strip, gender: learner_row[4])
      end
      bootcamper.update(uuid: learner_row[5].strip)
    end
  end

  def load_bootcampers_uuid
    file_name = "learners_uuid_since_june_2017.csv"
    base_path = Rails.root.join("public", "csv_data")
    csv_options = {
      headers: true,
      col_sep: ";",
      encoding: "ISO-8859-1",
      header_converters: :symbol,
      converters: :all
    }
    CSV.read(base_path.join(file_name).to_s, csv_options)
  end

  desc "Update dev framework flags for criteria"
  task :update_dev_framework_flags do
    Criterium.find_each do |criterium|
      dev_framework_criteria = %w(Quantity Quality Initiative Professionalism
                                  Communication Integration)
      if dev_framework_criteria.include? criterium.name
        criterium.belongs_to_dev_framework = true
        criterium.save
      end
    end
  end

  desc "Recalculate dev framework and holistic evaluation average"
  task :recalculate_evaluation_averages do
    evaluated_learners_ids = HolisticEvaluation.distinct.
                             pluck(:learner_program_id)

    evaluated_learners_ids.each do |learner_program_id|
      dev_framework_scores = HolisticEvaluation.
                             get_scores(learner_program_id, true)
      holistic_scores = HolisticEvaluation.get_scores(learner_program_id)

      dev_framework_average = EvaluationAverage.
                              calculate_average(dev_framework_scores)
      holistic_average = EvaluationAverage.calculate_average(holistic_scores)

      evaluation_average = HolisticEvaluation.
                           get_average_by_learner_id(learner_program_id)

      next if evaluation_average.nil?

      evaluation_average.dev_framework_average = dev_framework_average.
                                                 round(1)
      evaluation_average.holistic_average = holistic_average.
                                            round(1)
      evaluation_average.save
    end
  end

  desc "Migrate comments from Learner Program in backup to decisions"
  task migrate_comments_data_to_decisions_table: :environment do
    LearnerProgram.establish_connection(
      adapter: "postgresql",
      host: ENV["POSTGRES_BACKUP_HOST"],
      username: ENV["POSTGRES_BACKUP_USER"],
      password: ENV["POSTGRES_BACKUP_PASSWORD"],
      database: ENV["POSTGRES_BACKUP_DB"]
    )

    LearnerProgram.find_each do |learner|
      unless learner.decision_one_comment.blank?
        save_comment(1, learner.decision_one_comment, learner.id)
      end

      unless learner.decision_two_comment.blank?
        save_comment(2, learner.decision_two_comment, learner.id)
      end
    end

    LearnerProgram.connection.close
  end

  def save_comment(stage, comment, learner_program_id)
    decisions = Decision.where(
      learner_programs_id: learner_program_id, decision_stage: stage
    )

    if decisions.blank?
      create_decision(stage, comment, learner_program_id)
    else
      update_decisions(decisions, comment)
    end
  end

  def create_decision(stage, comment, learner_programs_id)
    Decision.new do |decision|
      decision.decision_stage = stage
      decision.comment = comment
      decision.decision_reason_id = 7
      decision.learner_programs_id = learner_programs_id
      decision.save
    end
  end

  def update_decisions(decisions, comment)
    decisions.each do |decision|
      decision.comment = comment
      decision.save
    end
  end

  desc "Populate values for cadences' days column"
  task populate_cadence_days: :environment do
    cadences = Cadence.all

    cadences.each do |cadence|
      if cadence.name == "Weekly"
        cadence.days = 5
      elsif cadence.name == "3 days"
        cadence.days = 3
      elsif cadence.name == "Everyday"
        cadence.days = 1
      end

      cadence.save
    end
  end

  desc "Set cadence and estimated duration for bootcamp programs"
  task set_bootcamp_cadence_and_duration: :environment do
    programs = Program.all
    weekly_cadence = Cadence.find_by_name("Weekly")

    programs.each do |program|
      next unless /^[B|b]ootcamp/.match?(program.name)

      program.cadence_id = weekly_cadence.id
      program.estimated_duration = 10
      program.save
    end
  end

  desc "Update description values for criteria"
  task update_criteria_descriptions: :environment do
    criteria = Criterium.all
    general_description = Criterium.criteria_descriptions
    description = Hash.new
    general_description.each_value do |criterion|
      description.merge!(criterion.reduce(:merge))
    end

    criteria.each do |criterion|
      criterion.description = description[criterion.name.to_s]
      criterion.save
    end
  end

  desc "Update cycles without start and end dates"
  task update_start_end_dates: :environment do
    cycles_centers = CycleCenter.where("start_date IS NULL OR end_date IS NULL")

    cycles_centers.each do |cycle_center|
      if (cycle_center.
          cycle.cycle == 6) && (cycle_center.
          center.name == "Kampala")
        cycle_center.start_date = "2018-02-19".to_date
        cycle_center.end_date = "2018-03-02".to_date
      elsif (cycle_center.
          cycle.cycle == 25) && (cycle_center.
          center.name == "Nairobi")
        cycle_center.start_date = "2018-02-26".to_date
        cycle_center.end_date = "2018-03-09".to_date
      elsif (cycle_center.
          cycle.cycle == 26) && (cycle_center.
          center.name == "Nairobi")
        cycle_center.start_date = "2018-03-22".to_date
        cycle_center.end_date = "2018-04-06".to_date
      elsif (cycle_center.
          cycle.cycle == 30) && (cycle_center.
          center.name == "Lagos")
        cycle_center.start_date = "2018-03-19".to_date
        cycle_center.end_date = "2018-03-30".to_date
      end
      cycle_center.save
    end
    puts "Dates updated successfully."
  end

  desc "Update targets table with performance and output targets"
  task update_performance_and_output_targets: :environment do
    if Rails.env != "test"
      Target.first.update(
        performance_target: 1.0,
        output_target: 2.0
      )
    end
  end

  desc "Populate target data for previous year and programs"
  task populate_program_years_target_data: :environment do
    if Rails.env != "test"
      program_ids = [4, 1]

      Year.create(year: "2017") do |year|
        program_ids.each do |program_id|
          year.program_years.new(
            target: Target.first,
            program_id: program_id
          )
        end
      end
    end
  end

  desc "Create missing bootcamp scores for KLA Week 1"
  task create_missing_scores_for_kla_week_one: :environment do
    bootcampers_emails = %w(
      meshachmish@gmail.com
      lutaayahuzaifahidris@gmail.com
      nnrobin37@gmail.com
      myalimul@gmail.com
      mariah.kakande@gmail.com
      reiosantos@yahoo.com
      kigozijonah4@gmail.com
      winga99@gmail.com
      marthamareal@gmail.com
      nakatuddesusan@gmail.com
      kjdumba@gmail.com
      collinewait17@gmail.com
      nammandaesther@gmail.com
      kh1@muni.ac.ug
      byarus45@gmail.com
      alexkayabula@gmail.com
      farooqp35h@gmail.com
      mubaruganda@gmail.com
      dianakiznaki@gmail.com
      toskingregory@icloud.com
      johnkal24@gmail.com
      awesomeme155@gmail.com
      shabunah10@gmail.com
    )
    # rubocop:disable LineLength
    scores = "{\r\n  \"Sheet1\": [\r\n    {\r\n      \"Email\": \"meshachmish@gmail.com\",\r\n      \"Quality\": \"0\",\r\n      \"Quantity\": \"1\",\r\n      \"Initiative\": \"1\",\r\n      \"Communication\": \"1\",\r\n      \"Professionalism\": \"1\",\r\n      \"Integration\": \"1\",\r\n      \"EPIC\": \"1\",\r\n      \"Learning Ability\": \"1\"\r\n    },\r\n    {\r\n\"Email\": \"lutaayahuzaifahidris@gmail.com\",\r\n      \"Quality\": \"1\",\r\n      \"Quantity\": \"1\",\r\n      \"Initiative\": \"1\",\r\n      \"Communication\": \"1\",\r\n      \"Professionalism\": \"1\",\r\n      \"Integration\": \"1\",\r\n      \"EPIC\": \"1\",\r\n      \"Learning Ability\": \"1\"\r\n    },\r\n    {\r\n      \"Email\": \"nnrobin37@gmail.com\",\r\n\"Quality\": \"0\",\r\n      \"Quantity\": \"0\",\r\n      \"Initiative\": \"1\",\r\n      \"Communication\": \"1\",\r\n      \"Professionalism\": \"1\",\r\n      \"Integration\": \"1\",\r\n      \"EPIC\": \"0\",\r\n      \"Learning Ability\": \"1\"\r\n    },\r\n    {\r\n      \"Email\": \"myalimul@gmail.com\",\r\n      \"Quality\": \"0\",\r\n      \"Quantity\": \"1\",\r\n \"Initiative\": \"1\",\r\n      \"Communication\": \"1\",\r\n      \"Professionalism\": \"1\",\r\n      \"Integration\": \"1\",\r\n      \"EPIC\": \"1\",\r\n      \"Learning Ability\": \"1\"\r\n    },\r\n    {\r\n      \"Email\": \"mariah.kakande@gmail.com\",\r\n      \"Quality\": \"1\",\r\n      \"Quantity\": \"1\",\r\n      \"Initiative\": \"1\",\r\n      \"Communication\": \"1\",\r\n \"Professionalism\": \"1\",\r\n      \"Integration\": \"1\",\r\n      \"EPIC\": \"1\",\r\n      \"Learning Ability\": \"1\"\r\n    },\r\n    {\r\n      \"Email\": \"reiosantos@yahoo.com\",\r\n      \"Quality\": \"1\",\r\n      \"Quantity\": \"1\",\r\n      \"Initiative\": \"1\",\r\n      \"Communication\": \"1\",\r\n      \"Professionalism\": \"1\",\r\n      \"Integration\": \"1\",\r\n \"EPIC\": \"1\",\r\n      \"Learning Ability\": \"1\"\r\n    },\r\n    {\r\n      \"Email\": \"kigozijonah4@gmail.com\",\r\n      \"Quality\": \"1\",\r\n      \"Quantity\": \"-1\",\r\n      \"Initiative\": \"1\",\r\n      \"Communication\": \"1\",\r\n      \"Professionalism\": \"1\",\r\n      \"Integration\": \"-1\",\r\n      \"EPIC\": \"1\",\r\n      \"Learning Ability\": \"1\"\r\n    },\r\n    {\r\n \"Email\": \"winga99@gmail.com\",\r\n      \"Quality\": \"1\",\r\n      \"Quantity\": \"-1\",\r\n      \"Initiative\": \"1\",\r\n      \"Communication\": \"1\",\r\n      \"Professionalism\": \"1\",\r\n      \"Integration\": \"1\",\r\n      \"EPIC\": \"1\",\r\n      \"Learning Ability\": \"1\"\r\n    },\r\n    {\r\n      \"Email\": \"marthamareal@gmail.com\",\r\n      \"Quality\": \"1\",\r\n \"Quantity\": \"1\",\r\n      \"Initiative\": \"1\",\r\n      \"Communication\": \"1\",\r\n      \"Professionalism\": \"1\",\r\n      \"Integration\": \"1\",\r\n      \"EPIC\": \"1\",\r\n      \"Learning Ability\": \"1\"\r\n    },\r\n    {\r\n      \"Email\": \"nakatuddesusan@gmail.com\",\r\n      \"Quality\": \"1\",\r\n      \"Quantity\": \"1\",\r\n      \"Initiative\": \"1\",\r\n \"Communication\": \"1\",\r\n      \"Professionalism\": \"1\",\r\n      \"Integration\": \"1\",\r\n      \"EPIC\": \"1\",\r\n      \"Learning Ability\": \"1\"\r\n    },\r\n    {\r\n      \"Email\": \"kjdumba@gmail.com\",\r\n      \"Quality\": \"1\",\r\n      \"Quantity\": \"1\",\r\n      \"Initiative\": \"1\",\r\n      \"Communication\": \"1\",\r\n      \"Professionalism\": \"1\",\r\n \"Integration\": \"1\",\r\n      \"EPIC\": \"1\",\r\n      \"Learning Ability\": \"1\"\r\n    },\r\n    {\r\n      \"Email\": \"collinewait17@gmail.com\",\r\n      \"Quality\": \"1\",\r\n      \"Quantity\": \"1\",\r\n      \"Initiative\": \"1\",\r\n      \"Communication\": \"1\",\r\n      \"Professionalism\": \"1\",\r\n      \"Integration\": \"1\",\r\n      \"EPIC\": \"1\",\r\n \"Learning Ability\": \"1\"\r\n    },\r\n    {\r\n      \"Email\": \"nammandaesther@gmail.com\",\r\n      \"Quality\": \"1\",\r\n      \"Quantity\": \"1\",\r\n      \"Initiative\": \"1\",\r\n      \"Communication\": \"1\",\r\n      \"Professionalism\": \"1\",\r\n      \"Integration\": \"1\",\r\n      \"EPIC\": \"1\",\r\n      \"Learning Ability\": \"1\"\r\n    },\r\n    {\r\n \"Email\": \"kh1@muni.ac.ug\",\r\n      \"Quality\": \"1\",\r\n      \"Quantity\": \"0\",\r\n      \"Initiative\": \"0\",\r\n      \"Communication\": \"1\",\r\n      \"Professionalism\": \"1\",\r\n      \"Integration\": \"1\",\r\n      \"EPIC\": \"0\",\r\n      \"Learning Ability\": \"0\"\r\n    },\r\n    {\r\n      \"Email\": \"byarus45@gmail.com\",\r\n      \"Quality\": \"1\",\r\n \"Quantity\": \"1\",\r\n      \"Initiative\": \"1\",\r\n      \"Communication\": \"2\",\r\n      \"Professionalism\": \"2\",\r\n      \"Integration\": \"1\",\r\n      \"EPIC\": \"1\",\r\n      \"Learning Ability\": \"2\"\r\n    },\r\n    {\r\n      \"Email\": \"alexkayabula@gmail.com\",\r\n      \"Quality\": \"0\",\r\n      \"Quantity\": \"0\",\r\n      \"Initiative\": \"1\",\r\n \"Communication\": \"1\",\r\n      \"Professionalism\": \"1\",\r\n      \"Integration\": \"1\",\r\n      \"EPIC\": \"1\",\r\n      \"Learning Ability\": \"1\"\r\n    },\r\n    {\r\n      \"Email\": \"farooqp35h@gmail.com\",\r\n      \"Quality\": \"0\",\r\n      \"Quantity\": \"1\",\r\n      \"Initiative\": \"1\",\r\n      \"Communication\": \"1\",\r\n      \"Professionalism\": \"1\",\r\n \"Integration\": \"2\",\r\n      \"EPIC\": \"1\",\r\n      \"Learning Ability\": \"1\"\r\n    },\r\n    {\r\n      \"Email\": \"mubaruganda@gmail.com\",\r\n      \"Quality\": \"1\",\r\n      \"Quantity\": \"1\",\r\n      \"Initiative\": \"1\",\r\n      \"Communication\": \"1\",\r\n      \"Professionalism\": \"1\",\r\n      \"Integration\": \"1\",\r\n      \"EPIC\": \"1\",\r\n \"Learning Ability\": \"1\"\r\n    },\r\n    {\r\n      \"Email\": \"dianakiznaki@gmail.com\",\r\n      \"Quality\": \"-1\",\r\n      \"Quantity\": \"1\",\r\n      \"Initiative\": \"1\",\r\n      \"Communication\": \"1\",\r\n      \"Professionalism\": \"1\",\r\n      \"Integration\": \"1\",\r\n      \"EPIC\": \"1\",\r\n      \"Learning Ability\": \"1\"\r\n    },\r\n    {\r\n      \"Email\": \"toskingregory@icloud.com\",\r\n      \"Quality\": \"-1\",\r\n      \"Quantity\": \"1\",\r\n      \"Initiative\": \"1\",\r\n      \"Communication\": \"1\",\r\n      \"Professionalism\": \"1\",\r\n      \"Integration\": \"1\",\r\n      \"EPIC\": \"1\",\r\n      \"Learning Ability\": \"1\"\r\n    },\r\n    {\r\n      \"Email\": \"johnkal24@gmail.com\",\r\n      \"Quality\": \"1\",\r\n      \"Quantity\": \"1\",\r\n      \"Initiative\": \"-1\",\r\n      \"Communication\": \"-1\",\r\n      \"Professionalism\": \"0\",\r\n      \"Integration\": \"1\",\r\n      \"EPIC\": \"0\",\r\n      \"Learning Ability\": \"0\"\r\n    },\r\n    {\r\n      \"Email\": \"awesomeme155@gmail.com\",\r\n      \"Quality\": \"-1\",\r\n      \"Quantity\": \"-1\",\r\n      \"Initiative\": \"1\",\r\n      \"Communication\": \"1\",\r\n      \"Professionalism\": \"1\",\r\n      \"Integration\": \"1\",\r\n      \"EPIC\": \"1\",\r\n      \"Learning Ability\": \"1\"\r\n    },\r\n    {\r\n      \"Email\": \"shabunah10@gmail.com\",\r\n      \"Quality\": \"1\",\r\n      \"Quantity\": \"-1\",\r\n      \"Initiative\": \"1\",\r\n      \"Communication\": \"1\",\r\n      \"Professionalism\": \"1\",\r\n      \"Integration\": \"1\",\r\n      \"EPIC\": \"1\",\r\n      \"Learning Ability\": \"1\"\r\n    }\r\n  ]\r\n}"
    # rubocop:enable LineLength
    scores = JSON.parse(scores)["Sheet1"]
    criteria_names = %w(Quality Quantity Initiative Communication
                        Professionalism Integration EPIC Learning\ Ability)
    criteria = criteria_names.map do |name|
      Criterium.find_by(name: name)
    end
    learner_programs = LearnerProgram.
                       where(centers: { name: "Kampala" },
                             cycles: { cycle: 9 }).
                       joins(cycle_center: :cycle).joins(cycle_center: :center).
                       includes(:holistic_evaluations, :bootcamper)
    learner_programs = learner_programs.select do |lp|
      bootcampers_emails.include?(lp.bootcamper.email) &&
        (lp.holistic_evaluations.count.zero? ||
          lp.holistic_evaluations.count == 8)
    end
    learner_programs.each do |learner_program|
      week_one_scores = scores.select do |s|
        s["Email"] == learner_program.bootcamper.email
      end.first
      data = criteria.map do |criterium|
        {
          "criterium_id" => criterium.id.to_s,
          "score" => week_one_scores[criterium.name].to_s,
          "comment" => ""
        }
      end
      hashed_scores = {}
      data.each_with_index do |item, index|
        hashed_scores[index.to_s] = item
      end

      holistic_scores = HolisticEvaluation.
                        parse_evaluation_scores(hashed_scores)

      dev_framework_scores = HolisticEvaluation.
                             parse_evaluation_scores(hashed_scores, true)

      averages_record = EvaluationAverage.
                        save_evaluation_averages(
                          holistic_scores,
                          dev_framework_scores,
                          learner_program.id
                        )
      hashed_scores.each_value do |evaluation|
        HolisticEvaluation.create!(
          learner_program_id: learner_program.id,
          criterium_id: evaluation["criterium_id"],
          score: evaluation["score"],
          comment: evaluation["comment"],
          evaluation_average_id: averages_record.id,
          created_at: Time.new(2018, 6, 29)
        )
      end
    end
  end

  desc "Create missing relations for KLA 12"
  task create_missing_relations_kla_12: :environment do
    learner_programs = LearnerProgram.
                       includes(:week_one_facilitator).
                       all.last(67).reject(&:camper_id)
    mike = Bootcamper.find_by_email("walimike139@gmail.com")
    mike.update(
      first_name: "Michael",
      last_name: "Robert",
      gender: "Male",
      greenhouse_candidate_id: 78_895_126
    )
    mikes_lp = learner_programs.select do |lp|
      lp.week_one_facilitator.email == "arnold.taremwa@andela.com"
    end.first
    mikes_lp.update(camper_id: mike.id)
    ahmad = Bootcamper.find_by_greenhouse_candidate_id("77604791")
    ahmad.update(
      email: "kyakuluahmed@gmail.com",
      first_name: "Kyakulumbye",
      last_name: "Ahmad",
      gender: "Male",
      greenhouse_candidate_id: 77_604_791
    )
    ahmeds_lp = learner_programs.select do |lp|
      lp.week_one_facilitator.email == "shakira.seruwagi@andela.com"
    end.first
    ahmeds_lp.update(camper_id: ahmad.id)
  end

  desc "Set decision one to in progress as default"
  task set_decision_one_to_default_value: :environment do
    LearnerProgram.where(decision_one: nil).
      update_all(decision_one: "In Progress")
  end
end
# rubocop:enable Metrics/BlockLength
