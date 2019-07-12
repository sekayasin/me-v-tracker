class Notifications.App
  constructor: ->
    @api = new Notifications.API()
    @ui = new Notifications.UI(@api.clearNotifications)

  onReceiveNotification: (notification) =>
    @ui.onReceiveNotification(notification)

  createNotification: (params) =>
    @api.createNotification({
      content: params.content
      recipient_emails: params.recipient_emails
      priority: params.priority
      group: params.group
    })

  @sendLfaNewLearnerNotification: (lfaList) =>
    $.each(lfaList, (index, list) ->
      notifications.createNotification({
        content: "You have been assigned a new Learner: <a class='assignedLearner-notification-link notification-link' href='/learners/#{list.camper_id}/#{list.learner_program_id}/scores'>#{list.learner}</a>",
        recipient_emails: "#{list.lfa}",
        priority: 'Normal',
        group: 'Assigned Learner(s)'
      })
    )

  @sendAdminNewProgramNotification: (adminList, programName) =>
    notifications.createNotification({
      content: "A new program has been created: <a class='newprogram-notification-link notification-link draft-program'>#{programName}</a>",
      recipient_emails: adminList.toString(),
      priority: 'Normal',
      group: 'New Program(s)'
    })

  @sendAdminFinalizedProgramNotification: (adminList, program) =>
    notifications.createNotification({
      content: "The program <a class='finalprogram-notification-link notification-link draft-program'>#{program.name}</a> is finalized and ready for use.",
      recipient_emails: adminList.toString(),
      priority: 'Normal',
      group: 'Finalized Program(s)'
    })

  @sendLfaOutputSubmissionNotification: (data) =>
    notifications.createNotification({
      content: "Hello! #{data.learner_name} has submitted an output on
        <a 
          class='submission-notification-link notification-link draft-program'
          phase-id='#{data.phase_id}'
          assessment-id='#{data.assessment_id}'
          assessment-name='#{data.output_name}'
          learner-program-id='#{data.learner_programs_id}'
          phase-name='#{data.phase_name}'
        >
          '#{data.output_name}'
        </a>",
      recipient_emails: data.lfa,
      priority: 'Normal',
      group: "Learner's Outputs"
    })

  @sendLearnerFeedbackNotification: (data) ->
    notifications.createNotification({
      content: """
        Hello! you have received a feedback from your LFA on
        <a class='learnerFeedback-notification-link notification-link'>
          <strong
            phase-id='#{data.phase_id}'
            assessment-id='#{data.assessment_id}'>
            #{data.assessment_name}
          </strong>
        </a>
        output
      """,
      recipient_emails: data.bootcamper_email,
      priority: 'Normal',
      group: "Feedback"
    })

  @sendLfaLearnerReflection: (data) =>
    notifications.createNotification({
      content: """
      Hello! #{data.learner_name} has submitted a reflection on
      <a class='learnerReflection-notification-link notification-link'
      assessment-id='#{data.assessment_id}'
      assessment-name='#{data.output_name}'
      phase-id='#{data.phase_id}'
      phase-name = '#{data.phase_name}'
      learner-program-id='#{data.learner_programs_id}'
      feedback-id='#{data.reflection.feedback_id}'>
      '#{data.output_name}'
      </a>
      in the phase <strong>#{data.phase_name}</strong>
      """
      recipient_emails: data.lfa_email,
      priority: 'Normal',
      group: "Learner's Reflections"
    })