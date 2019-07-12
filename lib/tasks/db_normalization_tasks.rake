# rubocop:disable Metrics/BlockLength
namespace :db do
  desc "populate programphases from phases table"
  task populate_programphases_from_phases: :environment do
    ProgramsPhase.destroy_all
    phases = Phase.select(:id, :program_id)
    phases.each do |phase|
      ProgramsPhase.create!(
        program_id: phase["program_id"],
        phase_id: phase["id"]
      )
    end
  end

  desc "populate program_ids from programsphases to phases table"
  task populate_program_ids_in_phases: :environment do
    programs_phases = ProgramsPhase.select(:program_id, :phase_id)
    programs_phases.each do |programs_phase|
      phase = Phase.where(id: programs_phase["phase_id"])[0]
      if phase.program_id.nil?
        phase.update(program_id: programs_phase["program_id"])
      else
        Phase.create!(
          name: phase.name, phase_duration: phase.phase_duration,
          phase_decision_bridge: phase.phase_decision_bridge,
          program_id: programs_phase["program_id"],
          created_at: phase.created_at, updated_at: phase.updated_at
        )
      end
    end
  end

  desc "populate year and target table"
  task populate_year_and_target_table: :environment do
    year = Year.create!
    target = Target.create!
    programs = Program.where("extract(year from created_at) = ?", year.year)
    programs.each do |program|
      year.program_years.create!(target: target, program_id: program.id)
    end
  end

  desc "populate program year id on learner Programs"
  task populate_program_year_id_on_learner_programs_table: :environment do
    program_years = ProgramYear.all
    program_years.each do |program_year|
      learner_programs = LearnerProgram.where(
        program_id: program_year.program_id
      )
      learner_programs.update_all(program_year_id: program_year.program_year_id)
    end
  end

  desc "Migrate language stacks from bootcampers to bootcampers language stacks"
  task migrate_language_stacks_to_bootcampers_language_stacks: :environment do
    bootcampers = Bootcamper.where.not(language_stack_id: nil)

    bootcampers.each do |bootcamper|
      BootcampersLanguageStack.create(
        camper_id: bootcamper.camper_id,
        language_stack_id: bootcamper.language_stack_id
      )
    end
  end

  desc "Populate cycles table with cycles from learner_programs table"
  task populate_cycles_table: :environment do
    disctinct_cycles = LearnerProgram.distinct.pluck(:cycle)
    disctinct_cycles.each { |cycle| Cycle.create(cycle: cycle) }
    puts "[*] -- ##{Cycle.count} cycles created"
  end

  desc "Populate centers table with centers from andela location api"
  task populate_centers_table: :environment do
    centers = [
      {
        "id" => "-JltZTD9iU0aD7j9Qr5m",
        "name" => "Lagos",
        "country" => "Nigeria"
      },
      {
        "id" => "-JqPKs52HaqLXCVQlwZL",
        "name" => "Nairobi",
        "country" => "Kenya"
      },
      {
        "id" => "-KmLM2bqzU0SzAtDboN9",
        "name" => "Kampala",
        "country" => "Uganda"
      },
      {
        "id" => "-LDDEpwg8xD5CBDTaeGq",
        "name" => "Abuja",
        "country" => "Nigeria"
      }
    ]
    centers.each do |center|
      Center.create(
        center_id: center["id"],
        name: center["name"],
        country: center["country"]
      )
    end
    puts "[*]#{Center.count} centers created"
  end

  desc "Populates cycles_centers table with data from learner_programs table"
  task populate_cycles_centers_table: :environment do
    dcc = LearnerProgram.distinct.pluck(
      :cycle,
      :city,
      :start_date,
      :end_date,
      :program_id
    )
    dcc.each do |cycle_number, city, start_date, end_date, program_id|
      cycle = Cycle.find_by_cycle(cycle_number.to_i)
      center = Center.find_by_name(city)
      populate_cycles_centers(
        cycle: cycle,
        center: center,
        start_date: start_date,
        end_date: end_date,
        program_id: program_id
      )
    end
    puts "[*]#{CycleCenter.count} cycles_centers created"
  end

  desc "Populates bootcampers_cycles_centers from learner_programs table"
  task populate_bootcampers_cycles_centers_table: :environment do
    distinct_bootcampers = LearnerProgram.all.pluck(
      :camper_id, :cycle, :city
    )
    distinct_bootcampers.each do |camper_id, cycle_number, city|
      cycle_id = Cycle.find_by_cycle(cycle_number).cycle_id
      center_id = Center.find_by_name(city).center_id
      cycle_center_id = CycleCenter.where(
        cycle_id: cycle_id,
        center_id: center_id
      )[0].cycle_center_id
      populate_bootcampers_cycles_centers(
        camper_id,
        cycle_center_id
      )
    end
    puts "[*]#{BootcamperCycleCenter.count} bootcampers_cycles_centers created"
  end

  desc "Populates points table with criteria points"
  task populate_criteria_points: :environment do
    criteria_points = {
      very_satisfied: 2,
      satisfied: 1,
      neutral: 0,
      unsatisfied: -1,
      very_unsatisfied: -2
    }

    criteria_points.each do |context, value|
      Point.create(context: context.to_s.titleize, value: value)
    end
  end

  desc "Creates and populates the new cycle_centers"
  task populate_new_cycle_centers_and_their_bootcampers: :environment do
    missing_data_mapping = [
      %w(Kampala 09),
      %w(Nairobi 29),
      %w(Lagos 31),
      %w(Lagos 33)
    ]
    missing_data_mapping.each do |mapping|
      cycle = Cycle.find_or_create_by(cycle: mapping[1].to_i)
      center = Center.find_by_name(mapping[0])
      new_bootcampers = LearnerProgram.where(
        cycle: mapping[1],
        city: mapping[0]
      )
      start_date = new_bootcampers.first.start_date
      end_date = new_bootcampers.first.end_date
      program = Program.find_by_name("BootCamp v1.5")
      cycle_center = CycleCenter.create(
        cycle: cycle,
        center: center,
        program_id: program.id,
        start_date: start_date,
        end_date: end_date
      )
      cycle_center.save!
      new_bootcampers_ids = new_bootcampers.pluck(:camper_id)
      new_bootcampers_ids.each do |camper_id|
        populate_bootcampers_cycles_centers(
          camper_id,
          cycle_center.cycle_center_id
        )
      end
    end
  end

  desc "Update learner_programs table with appropriate cycle_center"
  task update_learner_program_cycle_center: :environment do
    distinct_bootcampers = LearnerProgram.all.pluck(
      :camper_id, :cycle, :city
    )

    distinct_bootcampers.each do |camper_id, cycle_number, city|
      cycle = Cycle.find_by_cycle(cycle_number)
      center = Center.find_by_name(city)
      cycle_center = CycleCenter.find_by(
        cycle: cycle,
        center: center
      )
      update_learner_program_cycle_center(
        camper_id,
        cycle_center.id,
        cycle_number,
        city
      )
    end
  end

  desc "Restore learner programs cycle centers"
  task restore_learner_programs_cycle_center: :environment do
    LearnerProgram.all.each do |leaner_program|
      cycle_center = leaner_program.cycle_center
      next unless cycle_center

      restore_learner_programs_cycle_center(leaner_program,
                                            cycle_center.cycle_center_details)
    end
    puts "[*] learner programs table restored to original state"
  end

  desc "Populate facilitators table"
  task populate_facilitators_table: :environment do
    emails = LearnerProgram.pluck(:week_one_lfa, :week_two_lfa).flatten.uniq
    emails.each do |email|
      begin
        Facilitator.create!(email: email)
      rescue ActiveRecord::RecordInvalid
        next
      end
    end
    puts "[*] Populated faciliators table"
  end

  desc "Clear facilitators table"
  task clear_facilitators_table: :environment do
    Facilitator.delete_all
    puts "[*] Cleared faciliators table"
  end

  desc "Create foreign keys to facilitators table"
  task create_foreign_keys_to_facilitators_table: :environment do
    LearnerProgram.all.each do |program|
      week_one_lfa = Facilitator.find_by_email(program.week_one_lfa)
      week_two_lfa = Facilitator.find_by_email(program.week_two_lfa)
      if week_two_lfa.blank?
        week_two_lfa = Facilitator.find_by_email("unassigned@andela.com")
      end
      program.update(week_one_facilitator_id: week_one_lfa.id,
                     week_two_facilitator_id: week_two_lfa.id)
    end
    puts "[*] Created foreign keys to facilitators table"
  end

  desc "Restore data on lfa column"
  task restore_data_on_lfa_columns: :environment do
    LearnerProgram.all.each do |program|
      week_one_lfa = program.week_one_facilitator
      week_two_lfa = program.week_two_facilitator
      program.update(week_one_lfa: week_one_lfa.email,
                     week_two_lfa: week_two_lfa.email)
    end
    puts "[*] Restored data on week_one_lfa and week_two_lfa columns"
  end

  def populate_cycles_centers(**data)
    CycleCenter.create(
      center: data[:center],
      cycle: data[:cycle],
      start_date: data[:start_date],
      end_date: data[:end_date],
      program_id: data[:program_id]
    )
  end

  def populate_bootcampers_cycles_centers(camper_id, cycle_center_id)
    BootcamperCycleCenter.find_or_create_by(
      camper_id: camper_id,
      cycle_center_id: cycle_center_id
    )
  end

  def update_learner_program_cycle_center(
    camper_id,
    cycle_center_id,
    cycle_number,
    city
  )
    learner_program = LearnerProgram.find_by(
      camper_id: camper_id,
      cycle: cycle_number,
      city: city
    )
    learner_program.update_column(:cycle_center_id, cycle_center_id)
  end

  def restore_learner_programs_cycle_center(learner_program, details)
    columns = %i(city country cycle start_date end_date)
    columns.map do |column|
      if column == :city
        learner_program.update_column(column, details[:center])
      else
        learner_program.update_column(column, details[column])
      end
    end
  end

  desc "Add No Show in Decision status table"
  task add_no_show_row_in_decison_status_table: :environment do
    new_status = DecisionStatus.create(status: "No Show")
    new_reason = DecisionReason.create(reason: "Did not show up")
    other = DecisionReason.find_by(reason: "Other")
    decision_reason_ids = [new_reason.id, other.id]
    decision_reason_ids.each do |id|
      DecisionReasonStatus.create(
        decision_reason_id: id,
        decision_status_id: new_status.id
      )
    end
    puts "No Show in Decisions status has been populated successfully"
  end

  desc "Update all programs with null estimation_duration to 0"
  task update_program_estimation_duration: :environment do
    Program.where(estimated_duration: nil).update_all(estimated_duration: 0)
  end

  desc "Update notification group id in notification message table"
  task add_notification_group_id_to_notification_message_table: :environment do
    puts "Working on it. Just sit back and chill....."
    notification_groups = {
      "Assigned Learner(s)" => "You have been assigned a new Learner",
      "New Program(s)" => "A new program has been created",
      "Finalized Program(s)" => "The program",
      "Learner's Outputs" => "Hello! View learner ouput"
    }
    notification_groups.each do |group, content_snippet|
      notification_group = NotificationGroup.find_or_create_by(
        name: group
      )
      notification_message = NotificationsMessage.where(
        "content like ?", "%" + content_snippet + "%"
      ).all
      notification_message.update_all(
        notification_group_id: notification_group[:id]
      )
      puts "#{group} added successfully"
    end
    puts "Notification message table updated successfully"
  end

  desc "Update the finalized column of the feedback table"
  task set_existing_feedback_to_finalized: :environment do
    Feedback.update_all(finalized: true)
  end

  desc "update nps question table with questions for each week"
  task add_questions_to_nps_question_table: :environment do
    puts "NPS questions are being added, please wait..."

    nps_questions = [
      {
        question: "How easy is it to navigate VOF?",
        week: 1
      },
      {
        question: "How likely are you to recommend Andela bootcamp to others?",
        week: 2
      }
    ]
    nps_questions.each do |nps_question|
      NpsQuestion.find_or_create_by(
        question: nps_question[:question],
        week: nps_question[:week]
      )
    end
    puts "NPS questions successfully created"
  end

  desc "update NPS response table with response ratings"
  task add_ratings_to_nps_ratings_table: :environment do
    puts "NPS ratings are being added, please wait..."
    nps_ratings = [
      { rating: 1 },
      { rating: 2 },
      { rating: 3 },
      { rating: 4 },
      { rating: 5 },
      { rating: 6 },
      { rating: 7 },
      { rating: 8 },
      { rating: 9 },
      { rating: 10 }
    ]
    nps_ratings.each do |nps_rating|
      NpsRating.find_or_create_by(rating: nps_rating[:rating])
    end
    puts "NPS rating successfully created"
  end

  desc "Re-assign nps question and rating ids on nps responses table"
  task reassign_nps_response_question_and_rating_ids: :environment do
    if Rails.env.production?
      NpsResponse.destroy_all
    else
      puts "Re-assigning question &rating ids for all responses.. please wait"
      NpsResponse.find_each do |response|
        new_rating_id = NpsRating.find_by(rating: rand(1..10)).nps_ratings_id
        response.update(nps_ratings_id: new_rating_id)

        new_question_id = NpsQuestion.
                          offset(rand(NpsQuestion.count)).
                          first.
                          nps_question_id
        response.update(nps_question_id: new_question_id)
      end
      puts "All question and rating ids re assigned successfully"
    end
  end

  desc "Add Chart title and description fields to nps question tables"
  task add_title_description_to_nps_questions: :environment do
    NpsQuestion.reset_column_information
    NpsQuestion.find_each do |question|
      case question.question
      when "How easy is it to navigate VOF?"
        question.update(title: "VOF Usability NPS",
                        description: "Learners experience using VOF")
      when "How likely are you to recommend Andela bootcamp to others?"
        question.update(title: "Program NPS",
                        description: "Learners experience in the program")
      else
        puts "unknown question found"
      end
    end
    puts "Titles and descriptions added to nps questions"
  end

  desc "Add Nps rating of zero"
  task add_nps_rating_zero: :environment do
    NpsRating.create(rating: 0)
    puts "Nps rating of 0 added successfully"
  end
end
# rubocop:enable Metrics/BlockLength
