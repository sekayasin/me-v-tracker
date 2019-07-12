# Be sure to restart your server when you modify this file.

Rails.application.config.session_store(
  :cookie_store,
  key: ENV['session_key'] || '_vof-tracker_session'
)
