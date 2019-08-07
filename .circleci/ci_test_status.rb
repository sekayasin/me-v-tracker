#!/usr/bin/env ruby

require "json"

class CITestReportGenerator
  def initialize
    @build_url = ENV["CIRCLE_BUILD_URL"]
    @build_username = ENV["CIRCLE_USERNAME"]
    @test_status = ENV["TESTS_STATUS"]
    @git_commit_tag = ENV["GIT_COMMIT_TAG"]
    @git_commit_link = ENV["COMMIT_LINK"]
    @git_build_branch_commits = ENV["BUILD_BRANCH_COMMITS"]
    @current_branch = ENV["CIRCLE_BRANCH"]
    @workflow_link = ENV["WORKFLOW_LINK"]
    @release_branches = %w[master develop]
  end

  def create_test_status_hash(release_button)
    {
      channel: ENV["SLACK_NOTIFICATIONS_CHANNEL"],
      username: "TestNotifications",
      icon_emoji: ":andela:",
      text: "Tests for branch *#{@current_branch}* have finished running.\n \
#{@build_username}'s build, Git Commit Tag: \
*<#{@git_commit_link}|`#{@git_commit_tag}`>*",
      attachments: [{
        text: @test_report.to_s,
        fallback: "There was a problem, please try again.",
        callback_id: "deployment_stats",
        color: @test_status_color.to_s,
        attachment_type: "default",
        actions: [
          { text: "View Logs", type: "button", url: @build_url.to_s },
          { text: "View Github", type: "button",
            url: @git_build_branch_commits.to_s },
          release_button
        ]
      }]
    }
  end

  def create_test_report_data
    if @test_status == "failing"
      ["Aww, Snap! Some tests have failed. :sorry:", "danger", "#ff0000"]
    else
      ["Yaay! All Tests are passing. :monkey-dancing:", "primary", "#008000"]
    end
  end

  def create_release_button
    if @release_branches.include? @current_branch && @test_status == "failing"
      {
        text: "Release 🛫",
        type: "button",
        style: @test_status_theme.to_s,
        url: @workflow_link.to_s
      }
    end
  end

  def generate_test_status_report
    @test_report, @test_status_theme, \
    @test_status_color = create_test_report_data
    release_button = create_release_button
    test_status_hash = create_test_status_hash(release_button)
    File.open(".circleci/ci_test_status_report.json", "w") do |f|
      f.write(JSON.pretty_generate(test_status_hash))
    end
  end
end

circleci_report = CITestReportGenerator.new
circleci_report.generate_test_status_report
