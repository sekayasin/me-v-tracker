module Dashboard
  class CycleCenterMetricsFacade
    def initialize(data)
      @data = data
    end

    def report_data
      {
        week_one_cycle_metrics_report: week_one_report,
        learner_quantity_report: learner_quantity_report,
        gender_distribution_report: gender_distribution_report,
        week_two_cycle_metrics_report: week_two_report,
        lfa_to_learner_ratio_report: lfa_report_cycle,
        performance_and_output_quality_report: performance_quality_report,
        output_quality_report: output_quality_report
      }
    end

    def learner_quantity_rows
      cycles = []
      values = []
      header = %w(CYCLE)

      @data[:learner_quantity].each do |attribute, pair|
        cycles << attribute
        pair.each do |key, value|
          header << key.to_s.upcase
          values << value
        end
      end

      values = values.each_slice(values.length / cycles.length).to_a
      values.map.with_index do |value, index|
        value.insert(0, cycles[index])
        index.next
      end
      [header.uniq, values]
    end

    def learner_quantity_report
      header, lq_array = learner_quantity_rows

      CSV.generate(headers: true) do |csv|
        csv << header
        lq_array.each { |array| csv << array }
      end
    end

    def gender_distribution_rows
      header = %w(CYCLE)
      data = {}
      cycle = @data[:cycle].to_i
      gd_array = [cycle]

      @data[:gender_distribution].each do |key, value|
        case key
        when cycle.to_i
          data = value
          break
        end
      end

      data.each do |label, count|
        header << label.to_s.upcase
        gd_array << count
      end
      [header, gd_array]
    end

    def gender_distribution_report
      header, gd_array = gender_distribution_rows
      csv_generation(%w(Cycle and Center Gender Distribution Report),
                     header, gd_array)
    end

    def week_one_rows
      week_one_decisions = {}
      decisions = []
      scores = []

      @data[:week_one_decisions].each do |key, value|
        case key
        when @data[:cycle].to_i
          week_one_decisions = value
          break
        end
      end

      week_one_decisions.each do |key, pair|
        decisions << key.to_s
        pair.each_value do |value|
          scores << value
        end
      end
      [decisions, scores]
    end

    def week_one_report
      percentages = %w(Percentage)
      total_count = %w(Total\ Count)
      decisions, scores = week_one_rows
      decisions = decisions.insert(0, "Decisions")

      scores.each_with_index do |score, index|
        percentages << score if index.odd?
        total_count << score if index.even?
      end

      CSV.generate(headers: true) do |csv|
        csv << %W{Week One #{''} #{''} #{''} #{''}}
        csv << ["Cycle", @data[:cycle].to_i, "", "", "", ""]
        csv << decisions
        csv << total_count
        csv << percentages
      end
    end

    def week_two_rows
      week_two_metrics = []
      labels = []
      totals = []
      percentages = []

      @data[:week_two_cycle_metrics].each do |key, value|
        case key
        when @data[:cycle].to_i
          week_two_metrics = value
          break
        end
      end

      week_two_metrics.each do |key, value|
        case key
        when :labels
          labels = value
        when :totals
          value.each_value { |v| totals << v }
        when :percentage
          value.each_value { |v| percentages << v }
        end
      end
      [labels, totals, percentages]
    end

    def week_two_report
      labels, totals, percentages = week_two_rows
      labels = labels.insert(0, "Decisions")
      totals = totals.insert(0, "Total Count")
      percentages = percentages.insert(0, "Percentage")
      CSV.generate(headers: true) do |csv|
        csv << ["Week", "Two", "", ""]
        csv << ["Cycle", @data[:cycle].to_i, "Center", @data[:center]]
        csv << labels
        csv << totals
        csv << percentages
      end
    end

    def lfa_to_learner_percent_rows
      lfa_to_learner_percent = []
      percentages = []
      labels = []
      @data[:lfa_to_learner_percent].each do |key, value|
        case key
        when @data[:cycle].to_i
          lfa_to_learner_percent = value
          break
        end
      end
      lfa_to_learner_percent.each do |label, percentage|
        percentages << percentage
        labels << label
      end
      [labels, percentages]
    end

    def lfa_to_learner_ratio_rows
      ratio = []
      @data[:lfa_learner_ratio].each_value do |attribute|
        attribute.each do |key, value|
          case key
          when @data[:cycle].to_i
            ratio << value
            break
          end
        end
      end
      ratio
    end

    def lfa_report_cycle
      labels, percentages = lfa_to_learner_percent_rows
      ratio = lfa_to_learner_ratio_rows
      labels = labels.insert(0, "Labels")
      percentages = percentages.insert(0, "Percentages")
      ratio = ratio.insert(0, "Total Count")
      CSV.generate(headers: true) do |csv|
        csv << ["LFA TO LEARNER", "Ratio", "", "", ""]
        csv << ["Cycle", @data[:cycle].to_i, "Center", @data[:center], ""]
        csv << labels
        csv << ratio
        csv << percentages
      end
    end

    def performance_output_rows
      performance = []
      labels = []
      performance_and_output = {}
      @data[:performance_and_output_quality].each do |key, value|
        case key
        when @data[:cycle].to_i
          performance_and_output = value
          break
        end
      end

      performance_and_output.each do |attribute, data|
        labels << attribute
        performance << data
      end
      labels = labels.each_slice(3).to_a
      performance = performance.flatten.each_slice(4).to_a
      performance[0].delete_at(1)
      performance[1].insert(0, 2)
      labels + performance
    end

    def format_label(label)
      label = label.insert(0, "Label")
      target_index = label.find_index(:target)
      if target_index.nil?
        label.insert(1, "output_quality_target")
      else
        label[target_index] = "performance_quality_target"
      end
      label
    end

    def format_quality(quality)
      quality.insert(0, "Value")
    end

    def performance_quality_report
      performance_quality_label, _, performance_quality, =
        performance_output_rows
      csv_generation(%W(Performance Quality Report #{''}),
                     format_label(performance_quality_label),
                     format_quality(performance_quality))
    end

    def output_quality_report
      _, output_quality_label, _, output_quality =
        performance_output_rows
      csv_generation(%w(Output Quality Report),
                     format_label(output_quality_label),
                     format_quality(output_quality))
    end

    def csv_generation(header, first_row, second_row)
      CSV.generate(headers: true) do |csv|
        csv << header
        csv << first_row
        csv << second_row
      end
    end
  end
end
