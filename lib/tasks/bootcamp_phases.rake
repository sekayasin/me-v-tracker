namespace :app do
  desc "Add position values for bootcamp v1.5 programs phases"
  task add_position_values_to_programs_phases: :environment do
    program_phases = ProgramsPhase.where(program_id: 4)
    program_phases.each do |program_phase|
      case program_phase.phase_id
      when 23
        program_phase.position = 1
      when 24
        program_phase.position = 2
      when 25
        program_phase.position = 3
      when 26
        program_phase.position = 4
      when 27
        program_phase.position = 5
      when 28
        program_phase.position = 6
      when 29
        program_phase.position = 7
      end
      program_phase.save
    end
    puts "Position in Programs phases have been populated successfully"
  end
end
