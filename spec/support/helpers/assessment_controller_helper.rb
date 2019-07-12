module AssessmentControllerHelper
  def transform(submission_types)
    types = submission_types.inject({}) do |accumulator, entry|
      accumulator[entry.day] = { "0": [entry.title,
                                       entry.file_type,
                                       entry.position,
                                       entry.phase_id] }
      accumulator
    end
    types
  end
end
