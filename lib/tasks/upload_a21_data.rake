namespace :app do
  desc "Upload Andela 21 data"
  task upload_a21_data: :environment do
    data = []
    data << File.open("lib/assets/A21-Los-cycle3.xlsx")
    data << File.open("lib/assets/A21-Nbo-cycle2.xlsx")
    data.each { |sheet| get_all_data(sheet) }
    puts "Data successfully uploaded"
  end

  def create_cycle_center(sheet_data)
    location_params = {
      city: sheet_data.cell("b", 1),
      cycle: sheet_data.cell("b", 2).to_i,
      start_date: Date.parse(sheet_data.cell("b", 3)),
      end_date: Date.parse(sheet_data.cell("b", 4)),
      country: Center.get_country(sheet_data.cell("b", 1)),
      program_id: Program.find_by_name("Andela21 v0.1")[:id]
    }
    CycleCenter.get_or_create_cycle_center(location_params)
  end

  def get_all_data(file)
    spreadsheet_data = Roo::Spreadsheet.open(file)
    cycle = create_cycle_center(spreadsheet_data)[:id]
    current_row = 6
    total_rows = spreadsheet_data.last_row + 1
    spreadsheet_data.each_row_streaming(offset: 5, pad_cells: true) do |row|
      current_row += 1
      learner_data = learner_raw_data(row) if current_row <= total_rows
      next if learner_data.blank?

      upload_data = split_learner_name(learner_data)
      camper_id = get_learner_from_bc_table(upload_data)
      lfa_one_id = get_or_create_lfa_one(upload_data)
      lfa_two_id = get_or_create_lfa_two(upload_data)
      lp_details = { camper_id: camper_id, lfa_one_id: lfa_one_id,
                     lfa_two_id: lfa_two_id,
                     decision_one: upload_data[:decision_one],
                     decision_two: upload_data[:decision_two] }
      lp_id = create_learner_program(lp_details, cycle)[:id]
      get_scores(learner_data, lp_id, 35, :week_one)
      get_scores(learner_data, lp_id, 36, :week_two)
      get_scores(learner_data, lp_id, 37, :week_three)
      save_holistic_evaluations(learner_data[:holistic_week_one], lp_id)
      save_holistic_evaluations(learner_data[:holistic_week_two], lp_id)
      save_holistic_evaluations(learner_data[:holistic_week_three], lp_id)
    end
  end

  def create_learner_program(lp_details, cycle)
    LearnerProgram.create(camper_id: lp_details[:camper_id],
                          week_one_facilitator_id: lp_details[:lfa_one_id],
                          week_two_facilitator_id: lp_details[:lfa_two_id],
                          decision_one: lp_details[:decision_one],
                          decision_two: lp_details[:decision_two],
                          cycle_center_id: cycle,
                          program_id: 5)
  end

  def split_learner_name(learner)
    names = learner[:name].split
    learner_names = { first_name: names[1], last_name: names[0] }
    learner_names.merge(middle_name: names[2]) if names.length == 3
    learner.delete(:name)
    learner.merge(learner_names)
  end

  def get_learner_from_bc_table(learner)
    learner_details = {
      first_name: learner[:first_name], last_name: learner[:last_name],
      email: learner[:email],
      greenhouse_candidate_id: learner[:greenhouse_id]
    }
    Bootcamper.validate_camper(learner_details)[:camper_id]
  end

  def get_or_create_lfa_one(learner)
    Facilitator.find_or_create_by(email: learner[:lfa_one])[:id]
  end

  def get_or_create_lfa_two(learner)
    Facilitator.find_or_create_by(email: learner[:lfa_two])[:id]
  end

  def get_scores(learner, learner_program_id, phase, week)
    scores = remove_empty_assessments(learner[week])
    return if scores.blank?

    scores.each do |k, v|
      assessment = { id: 1, phase_id: phase, score: v.to_i }
      unless Assessment.find_by(name: k.to_s).nil?
        assessment[:id] = Assessment.find_by(name: k.to_s)[:id]
        Score.save_score(assessment, learner_program_id)
      end
    end
  end

  def remove_empty_assessments(learner_scores)
    learner_scores.each do |k, v|
      learner_scores.delete(k) if v == "N/A"
    end
    learner_scores
  end

  def save_holistic_evaluations(holistic, lp_id)
    learner_holistic = remove_empty_assessments(holistic)
    return if learner_holistic.blank?

    learner_holistic.each do |k, v|
      criteria_id = Criterium.find_by_name(k.to_s)[:id]
      params = { here: { criterium_id: criteria_id, score: v } }
      holistic_scores = HolisticEvaluation.parse_evaluation_scores(params)
      dev_framework_scores = HolisticEvaluation.
                             parse_evaluation_scores(params, true)
      average = EvaluationAverage.save_evaluation_averages(holistic_scores,
                                                           dev_framework_scores,
                                                           lp_id)
      HolisticEvaluation.save_holistic_evaluations(params, lp_id, average.id)
    end
  end

  def learner_raw_data(row)
    { name: row[1].value, email: row[2].value, greenhouse_id: row[3].value,
      lfa_one: row[0].value, lfa_two: row[86].value,
      decision_one: row[87].value, decision_two: row[88].value,
      week_one: week_one_output(row), holistic_week_one: week_one_holistic(row),
      week_two: week_two_output(row), holistic_week_two: week_two_holistic(row),
      week_three: week_three_output(row),
      holistic_week_three: week_three_holistic(row) }
  end

  def week_one_output(row)
    { "Project Management": row[4].value, "Version Control": row[5].value,
      "Front-End Development": row[6].value, "Programming Logic": row[7].value,
      "Test-Driven Development": row[8].value,
      "HTTP & Web Services": row[9].value, "Github Repository": row[10].value,
      "Databases": row[11].value, "Speaking to be Understood": row[14].value,
      "Excellence": row[15].value, "Passion": row[16].value,
      "Integrity": row[17].value, "Collaboration": row[18].value,
      "Commitment": row[19].value, "Openness To Feedback": row[20].value,
      "Progress Attempts": row[21].value }
  end

  def week_one_holistic(row)
    { "Quality": row[22].value, "Quantity": row[23].value,
      "Initiative": row[24].value, "Communication": row[25].value,
      "Professionalism": row[26].value, "Integration": row[27].value,
      "EPIC": row[28].value, "Learning Ability": row[29].value }
  end

  def week_two_output(row)
    { "Project Management": row[31].value, "Version Control": row[32].value,
      "Programming Logic": row[33].value,
      "Test-Driven Development": row[34].value,
      "HTTP & Web Services": row[35].value, "Databases": row[36].value,
      "Stakeholder Management": row[37].value,
      "Expectations Management": row[38].value, "Test Coverage": row[39].value,
      "Writing Professionally": row[40].value,
      "Speaking to be Understood": row[41].value, "Excellence": row[42].value,
      "Passion": row[43].value, "Integrity": row[44].value,
      "Collaboration": row[45].value, "Commitment": row[46].value,
      "Openness To Feedback": row[47].value,
      "Progress Attempts": row[48].value }
  end

  def week_two_holistic(row)
    { "Quality": row[49].value, "Quantity": row[50].value,
      "Initiative": row[51].value, "Communication": row[52].value,
      "Professionalism": row[53].value, "Integration": row[54].value,
      "EPIC": row[55].value, "Learning Ability": row[56].value }
  end

  def week_three_output(row)
    { "Project Management": row[58].value, "Version Control": row[59].value,
      "Programming Logic": row[60].value,
      "Front-End Development": row[61].value,
      "Holistic Thinking": row[62].value,
      "Writing Professionally": row[67].value,
      "Speaking to be Understood": row[68].value, "Excellence": row[69].value,
      "Passion": row[70].value, "Integrity": row[71].value,
      "Collaboration": row[72].value, "Commitment": row[73].value,
      "Openness To Feedback": row[74].value,
      "Progress Attempts": row[75].value }
  end

  def week_three_holistic(row)
    { "Quality": row[77].value, "Quantity": row[78].value,
      "Initiative": row[79].value, "Communication": row[80].value,
      "Professionalism": row[81].value, "Integration": row[82].value,
      "EPIC": row[83].value, "Learning Ability": row[84].value }
  end
end
