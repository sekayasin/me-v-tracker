class IndexFacade
  attr_reader :query_params, :search_params,
              :lfas, :cycles, :programs, :locations

  def initialize(params = nil)
    @query_params = get_query_object(params)
    @search_params = params[:search]
    week_one = 1
    week_two = 2
    @lfas1 = LearnerProgram.lfas(
      @query_params[:city],
      @query_params[:cycle],
      week_one
    )
    @lfas2 = LearnerProgram.lfas(
      @query_params[:city],
      @query_params[:cycle],
      week_two
    )
    term = @query_params[:program_id]

    @locations = LearnerProgram.program_locations(term)
    @cycles = LearnerProgram.cycles(
      @query_params[:program_id],
      @query_params[:city]
    )
    @programs = LearnerProgram.programs
  end

  def get_query_object(params)
    page_size = (params[:size] || 15).to_i
    cycles = build_filter_terms(params["cycle"])
    cycles.is_a?(Array) ? cycles.map!(&:to_i) : cycles = cycles.to_i
    filter_params = {
      program_id: build_filter_terms(params["program_id"]),
      city: build_filter_terms(params["city"]),
      cycle: cycles,
      week_one_lfa: build_filter_terms(params["week_one_lfa"]),
      week_two_lfa: build_filter_terms(params["week_two_lfa"]),
      decision_one: build_filter_terms(params["decision_one"]),
      decision_two: build_filter_terms(params["decision_two"]),
      page: params["page"] || 1
    }
    filter_params[:num_pages] = get_number_of_pages(page_size, filter_params)
    filter_params[:page_size] = page_size

    filter_params
  end

  def get_number_of_pages(page_size, filter_params)
    pages_data = RedisService.
                 get("learnerspage:number_of_pages." \
                         "#{page_size}.#{filter_params}")
    unless pages_data
      pages_data = get_bootcampers(filter_params).size
      RedisService.
        set("learnerspage:number_of_pages.#{page_size}.#{filter_params}",
            pages_data)
    end
    size = (pages_data / page_size)
    (pages_data % page_size).zero? ? size : size + 1
  end

  def get_bootcampers(query_params)
    data = %w(
      program_id
      city
      decision_one
      decision_two
      cycle
      week_one_lfa
      week_two_lfa
    )
    query = build_filter_query(data, query_params)
    # Return learner_programs starting from the most recently added
    if query.key?(:centers) || query.key?(:cycles)
      LearnerProgram.where(query).
        includes(cycle_center: :cycle).
        includes(cycle_center: :center).newest_first
    else
      LearnerProgram.includes(:bootcamper).where(query).newest_first
    end
  end

  def self.get_evaluation_averages(campers)
    campers.each do |camper|
      camper[:dev_framework_average] = EvaluationAverage.
                                       get_existing_average(
                                         camper[:learner_program_id],
                                         true
                                       )
      camper[:holistic_average] = EvaluationAverage.
                                  get_existing_average(
                                    camper[:learner_program_id]
                                  )
    end
  end

  def build_filter_query(data, query_params)
    query = {}
    temp_query = generate_query(data, query_params)
    cycle_center_query = temp_query[:cycle_center_query]
    filter_query = temp_query[:filter_query]

    unless filter_query.empty?
      clean_query(filter_query)
      query = { learner_programs: filter_query }
      query.merge!(cycle_center_query)
    end

    query
  end

  def generate_query(data, query_params)
    cycle_center_query = {}
    @filter_query = {}
    data.each do |filter|
      filter = filter.parameterize.to_sym
      next if query_params[filter] == "All" && query_params[filter]

      if %i[week_one_lfa week_two_lfa].include?(filter)
        filter_out_lfas(filter, query_params)
      else
        @filter_query[filter] = query_params[filter]
      end
      cycle_center_query.merge!(
        cycle_center_filter_query(filter, query_params)
      )
    end
    { cycle_center_query: cycle_center_query, filter_query: @filter_query }
  end

  def cycle_center_filter_query(filter, query_params)
    query = {}

    if filter == "city".to_sym
      query[:centers] = { name: query_params[filter] }
    elsif filter == "cycle".to_sym
      value = query_params[filter]
      return {} if value.equal? 0 # cater to 'All' filter for the Cycles

      query[:cycles] = { cycle: value }
    end

    query
  end

  def get_lfa(lfa_emails)
    unless lfa_emails.blank?
      Facilitator.where(email: lfa_emails).pluck(:id)
    end
  end

  def filter_out_lfas(filter, query)
    query = query[filter].split(",")
    case filter
    when :week_one_lfa
      @filter_query[:week_one_facilitator_id] = get_lfa(query)

    when :week_two_lfa
      @filter_query[:week_two_facilitator_id] = get_lfa(query)
    end
  end

  def clean_query(query)
    dirty_keys = %i(city cycle)
    dirty_keys.each do |key|
      if query.key? key
        query.delete(key)
      end
    end

    query
  end

  def table_data
    return get_bootcampers @query_params unless @search_params

    Bootcamper.search(@search_params.to_s.downcase, @query_params[:program_id])
  end

  def lfa_learners_data(facilitators_data, program_id)
    LearnerProgram.active.where(
      "(week_one_facilitator_id = :facilitator_id OR
    week_two_facilitator_id = :facilitator_id)",
      facilitator_id: facilitators_data,
      program_id: program_id
    )
  end

  def offset
    (@query_params[:page].to_i * @query_params[:page_size].to_i) -
      @query_params[:page_size].to_i
  end

  def phase
    @phase = Phase.first.id
  end

  def statuses
    statuses = RedisService.get("learnerspage:statuses")
    unless statuses
      statuses = DecisionStatus.get_all_statuses
      RedisService.set("learnerspage:statuses", statuses)
    end
    statuses
  end

  def build_filter_terms(values = "")
    unless values.nil?
      if values.include? ","
        values = values.split(",")
      elsif values == "null"
        values = "All"
      end
    end

    @term = values || "All"
  end
end
