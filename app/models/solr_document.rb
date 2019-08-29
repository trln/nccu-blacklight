# frozen_string_literal: true

require 'trln_argon'

class SolrDocument
  include Blacklight::Solr::Document
  include SolrDocumentBehavior
end
