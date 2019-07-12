module ScoresControllerHelper
  def get_current_phase(learner_details, phases, start_date)
    start_date ||= get_start_date(learner_details)
    phases_hash = {}
    phases.each do |phase|
      !!phase[2] && 1.upto(phase[2]) do
        if phases_hash.empty?
          initialize_start_date(phases_hash, phase, start_date)
        else
          set_date(phases_hash, phase)
        end
      end
    end
    format_current_phase(phases_hash, phases)
  end

  def set_date(phases_hash, phase)
    next_date = Date.parse(phases_hash.keys.last.to_s).next_day(1)
    value = { title: phase[1], index: phase[0] }
    business_date(next_date, phases_hash, value)
  rescue ArgumentError
    {}
  end

  def business_date(date, hash, value)
    if date.workday?
      hash[date.to_s] = value
      return hash
    end
    hash[date.to_s] = {}
    business_date(date.next_day(1), hash, value)
  end

  def initialize_start_date(phase_hash, phase, start_date)
    phase_start = Date.parse(start_date.to_s)
    phase_hash[phase_start.to_s] = { title: phase[1], index: phase[0] }
  rescue ArgumentError
    {}
  end

  def get_start_date(details)
    learner_programs = details[:learner_programs].
                       select { |target| target[:start_date].present? }
    if learner_programs.empty?
      return details[:learner_programs][-1][:start_date]
    end

    active_cycle = details[:learner].cycle_center.cycle
    active_center = details[:learner].cycle_center.center

    ongoing_program = learner_programs.
                      sort_by { |lp| lp[:start_date] }.
                      select(&method(:ongoing?)).
                      detect do |lp|
                        lp[:cycle] == active_cycle.cycle &&
                          lp[:center] == active_center.name
                      end
    return ongoing_program[:start_date] if ongoing_program

    details[:learner_programs][-1][:start_date]
  end

  def ongoing?(program)
    program[:end_date] && program[:end_date] >= Date.today
  end

  def format_current_phase(phases_hash, _phases)
    week_one = phases_hash.first(5).to_h
    week_two = phases_hash.select { |phases| phases > week_one.keys.last }
    if week_one.key?(Date.today.to_s)
      week_one.select { |phases| phases <= Date.today.to_s }
    else
      week_two.select { |phases| phases <= Date.today.to_s }
    end
  end
end
