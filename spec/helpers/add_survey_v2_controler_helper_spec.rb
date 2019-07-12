def survey_helper(cycle_center_id)
  {
    id: 1, title: "Title", description: "Description",
    start_date: Time.now, end_date: 10.days.from_now,
    recipients: [cycle_center_id],
    edit_response: true,
    survey_section_links: {}
  }
end

def base_question_helper
  {
    question: "Question", description: "Description",
    description_type: "text", position: 1, section: 1, is_required: false,
    survey_options: [{ option: "6", position: 1 },
                     { option: "3", position: 2 }]
  }
end

def grid_options_helper
  {
    survey_options: {
      rows: [{ option: "3", position: 1 }, { option: "4", position: 2 }],
      columns: [{ option: "3", position: 1 }, { option: "4", position: 2 }]
    }
  }
end

def file_option_helper(image_file)
  {
    files: { file_1: image_file, file_2: image_file },
    survey_options: [
      { option: "file_1", option_type: "image" },
      { option: "file_2", option_type: "image" }
    ]
  }
end

def section_links_helper
  {
    "section 2": { section_number: 1, question_number: 1, option_number: 1 }
  }
end
