class ProgramFeedback.API
	saveFeedback: (payload) ->
		return $.ajax(
			url: "/learner/program_feedback"
			type: "POST"
			data: payload
			success: (data) -> return data
			error: (request, error) -> return error
		)
	
	getFeedbackScheduleDetails: () ->
		return $.ajax(
			url: "/program_feedback/details"
			type: "GET"
		)

	saveScheduleFeedback: (payload) ->
		return $.ajax(
			url: "/schedule_feedback"
			type: "POST"
			data: payload
		)
