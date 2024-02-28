module SolrDocumentBehavior
  extend ActiveSupport::Concern

  included do
    send(:include, Blacklight::Solr::Document)
    # This is needed so that find will work correctly
    # from the Rails console with our Solr configuration.
    # Otherwise, it tries to use the non-existent document request handler.
    repository.blacklight_config.document_solr_path = :document
    repository.blacklight_config.document_solr_request_handler = nil
    use_extension(TrlnArgon::DocumentExtensions::Ris)
    use_extension(TrlnArgon::DocumentExtensions::Email)
    use_extension(TrlnArgon::DocumentExtensions::Sms)
    use_extension(Blacklight::Document::DublinCore)

    send(:include, TrlnArgon::SolrDocument)
    send(:include, TrlnArgon::ItemDeserializer)
    send(:include, RequestItem)

    # The following shows how to setup this blacklight document to display marc documents
    extension_parameters[:marc_source_field] = :marc_display
    extension_parameters[:marc_format_type] = :marcxml
    use_extension( Blacklight::Solr::Document::Marc) do |document|
     document.key?( :marc_display  )
    end
  
   field_semantics.merge!(    
                         :title => "title_display",
                         :author => "author_display",
                         :language => "language_facet",
                         :format => "format"
                         )

  end
end