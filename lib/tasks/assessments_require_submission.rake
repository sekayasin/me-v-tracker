namespace :app do
  desc "Add requires_submission values for assessments"
  task add_requires_submission_values_to_assessments: :environment do
    assessments_to_be_updated = [
      "Growth Mindset",
      "Writing Professionally",
      "Project Management",
      "Programming Logic",
      "Test-Driven Development",
      "Front-End Development",
      "Code Syntax Norms",
      "Git / Version Control",
      "Agile Methodology",
      "Object Oriented Programming",
      "Adaptability",
      "HTTP & Web Services",
      "Databases",
      "Creativity",
      "Tests Coverage",
      "Code Understanding"
    ]
    assessments = Assessment.where(name: assessments_to_be_updated)
    assessments.each do |assessment|
      assessment.update(requires_submission: true)
    end
  end
end
