module PhaseSpecHelper
  def get_the_current_due_date(phase, cycle_center, offset = 0)
    Phase.get_due_date(phase, cycle_center.start_date, offset)
  end

  def get_expected_due_date(phase, cycle_center)
    (phase.phase_duration - 1).business_days.after(
      cycle_center.start_date
    ).strftime("%B %d, %Y")
  end
end
