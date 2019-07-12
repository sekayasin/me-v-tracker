module Dashboard
  class ProgramMetricsFacade
    def initialize(data)
      @data = data
    end

    def report_data
      {
        historical_center_and_gender_distribution_report:
            gender_distribution_report,
        cycles_per_centre_report: cycle_center_report,
        lfa_to_learner_ratio_report: lfa_report,
        program_outcome_metrics_week_one_report: week_one_report,
        program_outcome_metrics_week_two_report: week_two_report,
        learners_dispersion_report: learner_dispersion_report
      }
    end

    def gender_distribution_report
      male, female, cities, male_percentage, female_percentage =
        with_headers(@data[:gender_distribution_data])
      CSV.generate(headers: true) do |csv|
        csv << %w(Historical Center Gender Distribution)
        csv << cities
        csv << male
        csv << female
        csv << male_percentage
        csv << female_percentage
      end
    end

    def with_headers(args)
      distributions = %w(Male\ Distribution Female\ Distribution)
      cities = %w(Cities)
      percentages = %w(Male\ Percentage Female\ Percentage)
      headers = distributions + cities + percentages
      args.map.with_index { |arg, index| arg.insert(0, headers[index]) }
    end

    def lfa_report
      week_one_lfa, week_one_learner,
          week_two_lfa, week_two_learner,
          percentages = @data[:lfa_to_learner_ratio]
      percentage_lfa_week_one,
          percentage_learner_week_one,
          percentage_lfa_week_two,
          percentage_learner_week_two = percentages

      CSV.generate(headers: true) do |csv|
        csv << ["", "LFA", "", "Learner", ""]
        csv << %W{#{''} Count Percentage Count Percentage}
        csv << ["Week One", week_one_lfa,
                percentage_lfa_week_one, week_one_learner,
                percentage_learner_week_one]
        csv << ["Week Two", week_two_lfa, percentage_lfa_week_two,
                week_two_learner, percentage_learner_week_two]
      end
    end

    def cycle_center_report
      cycles_per_center = @data[:cycles_per_centre]
      cities = %w(City) + cycles_per_center.keys
      cycles = %w(Cycle) + cycles_per_center.values
      CSV.generate(headers: true) do |csv|
        csv << %w{Cycle Per Center Report}
        csv << cities
        csv << cycles
      end
    end

    def week_one_report
      decisions, percentages, totals =
        report_rows_data(@data[:phase_one_metrics])
      csv_generation(%w(Week One Program Outcome Metrics Report),
                     decisions, percentages, totals)
    end

    def report_rows_data(data_set)
      totals = %w(Total)
      percentages = %w(Percentage)
      decisions = %w(Decision)
      data_set.each do |key, value|
        case key
        when :decisions
          decisions += value
        when :percentages
          percentages += value
        else
          totals += value
        end
      end
      [decisions, percentages, totals]
    end

    def csv_generation(header, first_row, second_row, third_row)
      CSV.generate(headers: true) do |csv|
        csv << header
        csv << first_row
        csv << second_row
        csv << third_row
      end
    end

    def week_two_report
      decisions, percentages, totals =
        report_rows_data(@data[:phase_two_metrics])
      csv_generation(%w(Week Two Program Outcome Metrics Report),
                     decisions, percentages, totals)
    end

    def learner_dispersion_report
      centers = %w(Center)
      percentages = %w(Percentage)
      totals = %w(Total\ Count)
      @data[:learners_dispersion_data].each do |key, value|
        case key
        when :centers
          centers += value
        when :percentages
          percentages += value
        when :totals
          totals += value
        end
      end
      CSV.generate(headers: true) do |csv|
        csv << ["Learners Dispersion", "", ""]
        csv << centers
        csv << totals
        csv << percentages
      end
    end
  end
end
