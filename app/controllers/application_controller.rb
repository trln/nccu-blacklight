class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout 'blacklight'

  protect_from_forgery with: :exception
  before_action only: :index do |controller|
    BotChallengePage::BotChallengePageController.bot_challenge_enforce_filter(controller, immediate: true)
  end

  #skip_after_action :discard_flash_if_xhr

end
