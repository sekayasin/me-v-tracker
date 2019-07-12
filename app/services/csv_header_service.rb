module CsvHeaderService
  extend self
  def second_csv_header(criteria, phases, evaluation_count)
    header = [
      "S/N", "UUID", "Greenhouse Candidate ID", "Name", "E-mail", "Gender",
      "Location", "Program", "Start Date", "Language/Stack", "Cycle",
      "Wk 1 LFA", "Wk 2 LFA", "Wk 1 Status", "Decision 1 Reason",
      "Decision 1 Comments", "Wk 2 Status", "Decision 2 Reason",
      "Decision 2 Comments", "Overall Avg", "Values Avg", "Output Avg",
      "Feedback Avg"
    ]

    evaluation_count.times do
      header.concat(criteria.map { |criterium| criterium[:name] })
    end

    phases.each do |phase|
      header.concat phase.assessments.map(&:name)
    end

    header
  end

  def first_csv_header(criteria, phases, evaluation_count)
    header = []

    header.concat [
      "Biodata", "Biodata", "Biodata", "Biodata", "Biodata", "Biodata",
      "Biodata", "Biodata", "Biodata", "Biodata", "Biodata", "Biodata",
      "Biodata", "Decisions", "Decisions", "Decisions", "Decisions",
      "Decisions", "Decisions", "Critical Numbers", "Critical Numbers",
      "Critical Numbers", "Critical Numbers"
    ]

    evaluation_count.times do |count|
      criteria.length.times { header << "Holistic Evaluation #{count + 1}" }
    end
    phases.each do |phase|
      phase.assessments.each { header << phase.name }
    end

    header
  end

  def first_holistic_header(camper)
    header_text = "Holistic Evaluation Performance for"
    ["", "", "#{header_text} #{camper.first_name} #{camper.last_name}"]
  end

  def second_holistic_header(camper_holistic_data)
    header = %w(Date Time Average)
    camper_holistic_data[0][:details].map do |key, _value|
      header.concat(["#{key} Score", "#{key} Comment"])
    end

    header
  end
end
