module AddLearnerHelpers
  def upload_file(file_name)
    fixture_file_upload(file_name, "application/vnd.ms-excel")
  end

  def post_learner_data(file_name)
    post :add, params: { country: "Nigeria",
                         city: "Lagos",
                         program_id: 1,
                         cycle: 22,
                         start_date: "2018-02-27",
                         end_date: Date.current,
                         dlc_stack_id: 2,
                         file: upload_file(file_name) }
  end
end
