module Descriptions
  extend ActiveSupport::Concern

  module ClassMethods
    def criteria_descriptions
      {
        "Output Quality" => output_quality_criteria,
        "Values Alignment" => values_alignment_criteria,
        "Feedback" => feedback_criteria
      }
    end

    def output_quality_criteria
      [
        { "Quality" => "The ability to deliver work output that meets\
          or exceeds expectations." },
        { "Quantity" => "The ability to consistently deliver work\
          output of sufficient quality." },
        { "Initiative" => "The ability to identify high value targets\
          for improvement and proactively prioritize and communicate them." },
        { "Communication" => "The ability to understand and make oneself\
          understood via both written and verbal communication." },
        { "Professionalism" => "The ability to act, react and communicate\
          in a manner that demonstrates respect." },
        { "Integration" => "The ability to embed oneself as a compatible,\
          vital member of a team and an organization at large." }
      ]
    end

    def values_alignment_criteria
      [
        { "EPIC" => "Excellence, Passion, Integrity, Collaboration." },
        { "Technology Leader" => "Technology Leader Description" },
        { "Human Empowerment" => "Human Empowerment Description" }
      ]
    end

    def feedback_criteria
      [
        { "Learning Ability" => "The ability to acquire knowledge or skill\
          by study, instruction, or experience." },
        { "Self-awareness" => "Self-awareness Description" }
      ]
    end
  end
end
