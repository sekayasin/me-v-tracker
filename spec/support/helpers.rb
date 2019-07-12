require "jwt"

module Helpers
  def stub_current_user(user)
    allow_any_instance_of(ApplicationController).
      to receive(:authentication).and_return(user)
  end

  def create_program(program)
    post :create, params: program, xhr: true
  end

  def stub_andelan
    allow(JWT).to receive(:decode).and_return(
      [
        {
          "UserInfo" => {
            "email" => "oluwatomi.duyile@andela.com",
            "first_name" => "Oluwatomi",
            "last_name" => "Duyile",
            "name" => "Duyile Oluwatomi",
            "andelan" => true,
            "picture" => "",
            "roles" => { "VOF_Admin" => "-KdN3P3b8y3X77X8AcJX" }
          }
        }
      ]
    )
  end

  def stub_andelan_panelist
    allow(JWT).to receive(:decode).and_return(
      [
        {
          "UserInfo" => {
            "email" => "efe.love@andela.com",
            "first_name" => "Efe",
            "last_name" => "Love",
            "name" => "Efe Love",
            "andelan" => true,
            "admin" => false,
            "panelist" => true,
            "picture" => "",
            "roles" => { "Guest" => "-KXGy1EB1oimjQgFim6I" }
          }
        }
      ]
    )
  end

  def stub_current_session_panelist
    page.set_rack_session(current_user_info:
    {
      name: "Efe Love",
      admin: false,
      andelan: true,
      panelist: true,
      picture: ""
    })
    jwt_token = JWT.encode({}, nil, "none")
    page.driver.browser.manage.add_cookie(name: "jwt-token", value: jwt_token)
  end

  def stub_admin_panelist
    allow(JWT).to receive(:decode).and_return(
      [
        {
          "UserInfo" => {
            "email" => "kingsley.eneja@andela.com",
            "first_name" => "Kingsley",
            "last_name" => "Eneja",
            "name" => "Kingsley Eneja",
            "andelan" => true,
            "admin" => true,
            "panelist" => true,
            "picture" => "",
            "roles" => { "VOF_Admin" => "-KdN3P3b8y3X77X8AcJX" }
          }
        }
      ]
    )
  end

  def stub_current_session_admin_panelist
    page.set_rack_session(current_user_info:
    {
      name: "Kingsley Eneja",
      admin: true,
      andelan: true,
      panelist: true,
      picture: ""
    })
    jwt_token = JWT.encode({}, nil, "none")
    page.driver.browser.manage.add_cookie(name: "jwt-token", value: jwt_token)
  end

  def stub_admin
    allow(JWT).to receive(:decode).and_return(
      [
        {
          "UserInfo" => {
            "email" => "juliet@andela.com",
            "first_name" => "Juliet",
            "last_name" => "Ezekwe",
            "name" => "Juliet Ezekwe",
            "andelan" => true,
            "admin" => true,
            "picture" => "",
            "roles" => { "VOF_Admin" => "-KdN3P3b8y3X77X8AcJX" }
          }
        }
      ]
    )
  end

  def stub_admin_two
    allow(JWT).to receive(:decode).and_return(
      [
        {
          "UserInfo" => {
            "email" => "daniel@andela.com",
            "first_name" => "Daniel",
            "last_name" => "Eze",
            "name" => "Daniel Eze",
            "andelan" => true,
            "admin" => true,
            "picture" => "",
            "roles" => { "VOF_Admin" => "-KdN3P3b8y3X77X8AcJX" }
          }
        }
      ]
    )
  end

  def stub_andelan_non_admin
    allow(JWT).to receive(:decode).and_return(
      [
        {
          "UserInfo" => {
            "email" => "jane.doe@andela.com",
            "first_name" => "Jane",
            "last_name" => "Doe",
            "name" => "Jane Doe",
            "andelan" => true,
            "panelist" => false,
            "admin" => false,
            "picture" => "",
            "roles" => { "Guest" => "-KXGy1EB1oimjQgFim6I" }
          }
        }
      ]
    )
  end

  def stub_andelan_non_admin_two
    allow(JWT).to receive(:decode).and_return(
      [
        {
          "UserInfo" => {
            "email" => "akeem.doe@andela.com",
            "first_name" => "akeem",
            "last_name" => "Doe",
            "name" => "Akeem Doe",
            "andelan" => true,
            "admin" => false,
            "picture" => "",
            "roles" => { "Guest" => "-KXGy1EB1oimjQgFim6I" }
          }
        }
      ]
    )
  end

  def stub_non_andelan
    allow(JWT).to receive(:decode).and_return(
      [
        {
          "UserInfo" => {
            "email" => "akinrelesimi@gmail.com",
            "first_name" => "Simi",
            "last_name" => "Akinrele",
            "name" => "Simi Akinrele",
            "andelan" => false,
            "picture" => "",
            "roles" => { "Guest" => "-KXGy1EB1oimjQgFim6I" }
          }
        }
      ]
    )
  end

  def stub_non_andelan_bootcamper(user)
    allow(JWT).to receive(:decode).and_return(
      [
        {
          "UserInfo" => {
            "email" => user.email,
            "first_name" => user.first_name,
            "last_name" => user.last_name,
            "name" => user.name,
            "andelan" => false,
            "learner" => true,
            "picture" => "",
            "roles" => { "Guest" => "-KXGy1EB1oimjQgFim6I" }
          }
        }
      ]
    )
  end

  def stub_current_session
    page.set_rack_session(current_user_info:
    {
      name: "Duyile Oluwatomi",
      admin: false,
      andelan: true,
      picture: ""
    })
    jwt_token = JWT.encode({}, nil, "none")
    page.driver.browser.manage.add_cookie(name: "jwt-token", value: jwt_token)
  end

  def stub_learner_cookie
    allow(JWT).to receive(:decode).and_return(
      [
        {
          "UserInfo" => {
            "email" => "vof.learner@gmail.com",
            "first_name" => "Learner",
            "last_name" => "Vof",
            "name" => "Vof Learner",
            "andelan" => false,
            "learner" => true,
            "picture" => "",
            "roles" => { "Guest" => "-KXGy1EB1oimjQgFim6I" }
          }
        }
      ]
    )
  end

  def stub_learner_session
    page.set_rack_session(current_user_info:
    {
      name: "Vof Learner",
      admin: false,
      andelan: false,
      picture: "",
      email: "vof.learner@gmail.com",
      learner: true
    })
    jwt_token = JWT.encode({}, nil, "none")
    page.driver.browser.manage.add_cookie(name: "jwt-token", value: jwt_token)
  end

  def stub_current_session_non_admin
    page.set_rack_session(current_user_info:
    {
      name: "Jane Doe",
      admin: false,
      andelan: true,
      picture: ""
    })
    jwt_token = JWT.encode({}, nil, "none")
    page.driver.browser.manage.add_cookie(name: "jwt-token", value: jwt_token)
  end

  def stub_current_session_bootcamper(user)
    page.set_rack_session(current_user_info:
    {
      name: user.last_name + " " + user.last_name,
      email: user.email,
      admin: false,
      andelan: false,
      picture: "",
      learner: true
    })
    jwt_token = JWT.encode({}, nil, "none")
    page.driver.browser.manage.add_cookie(name: "jwt-token", value: jwt_token)
  end

  def clear_session
    page.set_rack_session(current_user_info: nil)
    page.driver.browser.manage.delete_cookie("jwt-token")
  end

  def stub_camper_progress(value)
    allow(LearnerProgram).
      to receive(:update_campers_progress).and_return(value)
  end

  def stub_allow_admin
    allow(controller).to receive_message_chain(:helpers, :admin?)
  end

  def stub_export_csv
    allow(BootcampersCsvService).to receive(:generate_report).
      and_return(first_csv_header)
  end

  def wait_for_ajax
    return unless respond_to?(:evaluate_script)

    wait_until { finished_all_ajax_requests? }
  end

  def attach_spreadsheet_file(filename)
    attach_file(
      "upload_learners_file",
      "#{Rails.root}/spec/fixtures/#{filename}",
      visible: false
    )
  end

  def stub_admin_data_success
    admin_list = {
      "values": [
        {
          "id": "-random_ID",
          "name": "Test Admin",
          "email": "test-user-admin@andela.com"
        },
        {
          "id": "-another_random_ID",
          "name": "Duyile Oluwatomi",
          "email": "oluwatomi.duyile@andela.com"
        }
      ],
      "total": 2
    }

    allow_any_instance_of(AdminService).
      to receive(:get_admins).and_return(admin_list.as_json)
  end

  def upload_output_file(filename, target = "fileUpload")
    attach_file(
      target,
      "#{Rails.root}/spec/fixtures/#{filename}",
      visible: false
    )
  end

  def stub_admin_data_failure
    error_message = {
      "error": "an error occured"
    }

    allow_any_instance_of(AdminService).
      to receive(:get_admins).and_return(error_message.as_json)
  end

  def stub_current_session_admin
    page.set_rack_session(current_user_info:
    {
      name: "Juliet Ezekwe",
      email: "juliet@andela.com",
      admin: true,
      andelan: true,
      picture: ""
    })
    jwt_token = JWT.encode({}, nil, "none")
    page.driver.browser.manage.add_cookie(name: "jwt-token", value: jwt_token)
  end

  def stub_current_session_admin_two
    page.set_rack_session(current_user_info:
    {
      name: "Daniel Eze",
      email: "daniel@andela.com",
      admin: true,
      andelan: true,
      picture: ""
    })
    jwt_token = JWT.encode({}, nil, "none")
    page.driver.browser.manage.add_cookie(name: "jwt-token", value: jwt_token)
  end

  private

  def finished_all_ajax_requests?
    evaluate_script("!window.jQuery") || evaluate_script("jQuery.active").zero?
  end

  def wait_until(max_execution_time_in_seconds = Capybara.default_max_wait_time)
    Timeout.timeout(max_execution_time_in_seconds) do
      loop do
        if yield
          return true
        else
          sleep(1.00)
          next
        end
      end
    end
  end
end
