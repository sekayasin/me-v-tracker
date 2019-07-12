module BootcampersHelper
  def uploaded_cycle_url
    "/?program_id=#{@learner_program[:program_id]}&" \
      "city=#{@learner_program[:city]}&cycle=#{@learner_program[:cycle]}&" \
      "decision_one=All&decision_two=All&user_action=f"
  end

  def display_error_message(error)
    if error[:email].count == 1
      "This email address occurs more than once:"
    else
      "The following email addresses occur more than once:"
    end
  end

  def redirect_non_admin
    unless helpers.admin?
      redirect_to index_path
    end
  end

  def program_options
    finalized_programs = Program.get_finalized_programs
    finalized_programs.sort do |first_program, second_program|
      first_program[0].capitalize <=> second_program[0].capitalize
    end
  end

  def save_decision(bootcamper, decision_params)
    if bootcamper.update(decision_params)
      flash[:notice] = "decision-comments-success"
    else
      flash[:error] = bootcamper.errors.full_messages[0]
    end
  end

  def invite_learners(data)
    users = sanitize_data(data)
    invite users
  end

  def sanitize_data(valid_data)
    invite_list = []
    if Rails.env == "production"
      valid_data[0].each do |learners_data|
        user = { firstname: learners_data[:first_name],
                 lastname: learners_data[:last_name],
                 email: learners_data[:email] }
        invite_list << user
      end
    else
      invite_list = create_test_invite(valid_data)
    end

    invite_list
  end

  def create_test_invite(valid_data)
    test_invite = false
    valid_data[0].each do |learner|
      if learner[:email].strip.casecmp("vof.learner@gmail.com").zero?
        test_invite = true
      end
    end

    if test_invite
      return [{ firstname: "vof",
                lastname: "learner",
                email: "vof.learner@gmail.com" }]
    else
      return ""
    end
  end

  def invite(users)
    unless users.blank?
      InviteLearnersJob.perform_later(users)
    end
  end
end
