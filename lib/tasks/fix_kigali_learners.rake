namespace :app do
  desc "Remove duplicate Kigali center"
  task remove_duplicate_center_kigali: :environment do
    kigali = Center.where(name: "Kigali", country: "Rwanda")[0]
    rouge = Center.where(name: "Kigali", country: "Kenya")[0]
    if rouge
      rouge.cycles_centers.update_all(center_id: kigali.id)
      rouge.delete
    end
  end

  desc "Fixup bootcampers data & learners programs"
  task fixup_bootcampers_data: :environment do
    if Rails.env.production? || Rails.env.development?
      greenhouse_ids = %w(89849987 88781992 91049619 90940247 89195325)
      greenhouse_ids.each do |greenhouse_id|
        camper = Bootcamper.find_by(greenhouse_candidate_id: greenhouse_id)
        program = LearnerProgram.get_latest_learner_program(camper.id)
        program.delete
      end
    end
  end
end
