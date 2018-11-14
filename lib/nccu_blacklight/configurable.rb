# frozen_string_literal: true

module NccuBlacklight
  module Configurable
    extend ActiveSupport::Concern
    # rubocop:disable Metrics/BlockLength
    included do
      # ILLiad base URLs for DUL & professional school libraries.
      # =========================================================
      mattr_accessor :illiad_main_base_url do
        ENV['ILLIAD_MAIN_BASE_URL'] ||= 'https://nccu.illiad.oclc.org/illiad/ncx/illiad.dll'
      end

      mattr_accessor :illiad_law_base_url do
        ENV['ILLIAD_LAW_BASE_URL'] ||= 'https://nccu.illiad.oclc.org/illiad/nclaw/illiad.dll'
      end
    end
    # rubocop:enable Metrics/BlockLength
    module ClassMethods
      def configure
        yield self
      end
    end
  end
end