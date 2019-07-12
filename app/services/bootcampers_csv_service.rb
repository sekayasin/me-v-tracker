class BootcampersCsvService
  class << self
    include CsvHeaderService
    include CamperDataService
    include FilterService

    attr_accessor :phases, :city, :cycle, :decision_one,
                  :decision_two, :week_one_lfa, :week_two_lfa

    def generate_report(filter_params, &block)
      @program_id = filter_params[:program_id]
      @city = build_filter_terms(filter_params[:city])
      @cycle = build_filter_terms(filter_params[:cycle])
      @status_decision1 = build_filter_terms(filter_params[:decision_one])
      @status_decision2 = build_filter_terms(filter_params[:decision_two])
      @week_one_lfa = build_filter_terms(filter_params[:week_one_lfa])
      @week_two_lfa = build_filter_terms(filter_params[:week_two_lfa])

      set_params
      @evaluation_count = HolisticEvaluation.
                          program_max_evaluations(@program_id)

      @phases = Program.find_by_id(@program_id).phases.includes(:assessments)
      @criteria = Criterium.get_program_criteria(@program_id)
      first_header = CsvHeaderService.first_csv_header(
        @criteria, @phases, @evaluation_count
      )

      second_header = CsvHeaderService.second_csv_header(
        @criteria, @phases, @evaluation_count
      )

      yield CSV.generate_line(first_header, headers: true)
      yield CSV.generate_line(second_header)
      generate_csv_data(&block)
    end

    def set_params
      @city = check_if_nil(@city)
      @cycle = check_if_nil(@cycle)
      @status_decision1 = check_if_nil(@status_decision1)
      @week_one_lfa = check_if_nil(@week_one_lfa)
      @week_two_lfa = check_if_nil(@week_two_lfa)
      @status_decision2 = nil if @status_decision2.empty? ||
                                 @status_decision2 == "All" &&
                                 @status_decision1 != "Advanced"
    end

    def check_if_nil(param)
      param.empty? || param == "All" ? nil : param
    end

    def generate_csv_data
      serial_number = 1
      campers = get_campers
      campers.uncached do
        campers.each do |camper|
          camper_score = CamperDataService.get_camper_score(
            camper.scores, @phases
          )
          camper_data = CamperDataService.get_camper_data(serial_number, camper)
          camper_holistic_data = CamperDataService.get_camper_holistic_data(
            camper.id, @program_id, @evaluation_count, @criteria
          )
          camper_data.concat(camper_holistic_data)
          camper_row = camper_data.concat(camper_score)
          yield CSV.generate_line(camper_row)
          serial_number += 1
        end
      end
      GC.start(full_mark: true, immediate_sweep: true)
    end

    def get_campers
      LearnerProgram.order(:camper_id).includes(
        :week_one_facilitator,
        :week_two_facilitator,
        :bootcamper,
        :program,
        :scores,
        :dlc_stack,
        decisions: :decision_reason
      ).
        joins(cycle_center: :cycle).
        joins(cycle_center: :center).
        where(build_query)
    end

    def sanitize_decision_param(decision)
      return if decision == "All"

      decision = decision.split(",") unless decision.is_a? Array
      decision.map do |value|
        value.underscore.humanize.split.map(&:capitalize).join(" ")
      end
    end

    def build_query
      query = {}
      query[:centers] = { name: @city } if @city
      query[:cycles] = { cycle: @cycle } if @cycle
      query[:program_id] = @program_id if @program_id
      if @week_one_lfa
        query[:week_one_facilitator] = Facilitator.find_by(email: @week_one_lfa)
      end
      if @week_two_lfa
        query[:week_two_facilitator] = Facilitator.find_by(email: @week_two_lfa)
      end
      if @status_decision1 && @status_decision1 != "All"
        query[:decision_one] = sanitize_decision_param(@status_decision1)
      end
      if @status_decision2 && @status_decision2 != "All"
        query[:decision_two] = sanitize_decision_param(@status_decision2)
      end
      query
    end

    def generate_holistic_evaluation_report(camper_holistic_data, camper)
      CSV.generate(headers: true) do |csv|
        csv << CsvHeaderService.first_holistic_header(camper)
        csv << CsvHeaderService.second_holistic_header(camper_holistic_data)
        camper_holistic_data.each do |holistic_data|
          csv << CamperDataService.holistic_csv_data(holistic_data)
        end
      end
    end
  end
end
