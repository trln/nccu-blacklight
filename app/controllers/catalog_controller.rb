# frozen_string_literal: true
class CatalogController < ApplicationController

  include BlacklightRangeLimit::ControllerOverride

  include Blacklight::Catalog
  include Blacklight::Marc::Catalog

  # CatalogController behavior and configuration for TrlnArgon
  include TrlnArgon::ControllerOverride



  configure_blacklight do |config|
    config.add_show_tools_partial(:citation,
      icon: 'fa fa-quote-left',
      if: false)
    # Add Request button using Blacklight's extensible "tools" for
    # index & show view
    config.add_show_tools_partial(:request_button, partial: 'request_button')
    config.add_results_document_tool(:request_button, partial: 'request_button')

    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    config.default_solr_params = {
      rows: 10,
      spellcheck: 'true'
    }

    config.home_facet_fields.delete(TrlnArgon::Fields::AVAILABLE_FACET)
    config.facet_fields.delete(TrlnArgon::Fields::AVAILABLE_FACET)
    
    config.home_facet_fields.delete(TrlnArgon::Fields::LANGUAGE_FACET)
    config.home_facet_fields.delete(TrlnArgon::Fields::CALL_NUMBER_FACET)

    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select'

    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SearchHelper#solr_doc_params) or
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    #config.default_document_solr_params = {
    #  qt: 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # fl: '*',
    #  # rows: 1,
    #  # q: '{!term f=id v=$id}'
    #}

    # solr field configuration for search results/index views
    #config.index.thumbnail_field = 'thumbnail_path_ss'

    # solr field configuration for document/show views
    #config.show.title_field = 'title_display'
    #config.show.display_type_field = 'format'
    #config.show.thumbnail_field = 'thumbnail_path_ss'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    #
    # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    # make Advanced Search facet fields NOT limited to those configured as home_facets.
    def advanced_search
      (@response, _deprecated_document_list) = blacklight_advanced_search_form_search_service.search_results do |builder|
        builder.except(:only_home_facets)
      end
    end

    config.advanced_search[:form_solr_parameters] = {
      # NOTE: You will not get any facets back
      #       on the advanced search page
      #       unless defType is set to lucene.
      'defType' => 'lucene',
      'facet.field' => [TrlnArgon::Fields::AVAILABLE_FACET.to_s,
                        TrlnArgon::Fields::ACCESS_TYPE_FACET.to_s,
                        TrlnArgon::Fields::RESOURCE_TYPE_FACET.to_s,
                        TrlnArgon::Fields::PHYSICAL_MEDIA_FACET.to_s,
                        TrlnArgon::Fields::LANGUAGE_FACET.to_s,
                        TrlnArgon::Fields::CALL_NUMBER_FACET.to_s,
                        TrlnArgon::Fields::LOCATION_HIERARCHY_FACET.to_s],
      'f.resource_type_f.facet.limit' => -1, # return all resource type values
      'f.language_f.facet.limit' => -1, # return all language facet values
      'f.call_number_f.facet.limit' => -1, # return all call number values
      'f.location_hierarchy_f.facet.limit' => -1, # return all loc facet values
      'f.physical_media_f.facet.limit' => -1, # return all phys med facet values
      'facet.limit' => -1, # return all facet values
      'facet.sort' => 'index' # sort by byte order of values
    }


    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.


    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Configuration for autocomplete suggestor
    # config.autocomplete_enabled = true
    # config.autocomplete_path = 'suggest'
  end

  # get search results from the solr index
     def index
       if (params.keys - %w[controller action]).empty?
         cache_key = "#{params.fetch('controller', '')}/"\
                     "#{params.fetch('action', '')}"\
                     "facet_query"\
       end

       (@response, @document_list) =  if cache_key
         Rails.cache.fetch("#{cache_key}", expires_in: 1.hour) do
           search_service.search_results
         end
       else
         search_service.search_results
       end

       respond_to do |format|
         format.html { store_preferred_view }
         format.rss  { render :layout => false }
         format.atom { render :layout => false }
         format.json do
           @presenter = Blacklight::JsonPresenter.new(@response,
                                                      @document_list,
                                                      facets_from_request,
                                                      blacklight_config)
         end
         additional_response_formats(format)
         document_export_formats(format)
       end
     end
end
