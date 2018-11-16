# frozen_string_literal: true
require 'nccu_blacklight'

NccuBlacklight.configure do |config|
  # Configs unique to local skin, separate from TrlnArgon
  config.illiad_main_base_url = ENV['ILLIAD_MAIN_BASE_URL']
  config.illiad_law_base_url = ENV['ILLIAD_LAW_BASE_URL']
end