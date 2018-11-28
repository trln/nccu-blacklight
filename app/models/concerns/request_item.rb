module RequestItem
  extend ActiveSupport::Concern

  def nccu_requestable?
    nccu_owned? && physical_item?
  end

  def trln_requestable?
    trln_partner_owned? && physical_item?
  end

  def illiad_request_url_default
    [NccuBlacklight.illiad_main_base_url, illiad_request_params].join('?')
  end

  def illiad_request_params
    if fetch(TrlnArgon::Fields::RESOURCE_TYPE, []).include?('Journal, Magazine, or Periodical')
      params = illiad_request_params_fixed.merge(illiad_request_params_journal_variable)
    else
      params = illiad_request_params_fixed.merge(illiad_request_params_book_variable)
    end
    params.to_query
  end

  private

  def nccu_owned?
    record_owner == 'nccu'
  end

  def trln_partner_owned?
    record_owner.in?(%w[unc ncsu duke])
  end

  def physical_item?
    fetch(TrlnArgon::Fields::ACCESS_TYPE, []).include?('At the Library')
  end

  # These values are consistent, no matter the item or the home library's
  # ILLiad instance
  def illiad_request_params_fixed
    {
      'Value': 'GenericRequestTRLNLoan',
      'RequestType': 'null',
      'Action': '10',
      'IlliadForm': 'Logon',
      'CitedPages': 'TRLN',
      'ESPNumber': oclc_number,
      'Location': item_url_absolute
    }
  end

  def illiad_request_params_book_variable
    {
      'genre': 'TRLNbook',
      'form': '21',
      'LoanTitle': fetch(TrlnArgon::Fields::TITLE_MAIN, ''),
      'LoanEdition': edition,
      'LoanPublisher': imprint_main_for_header_display,
      'LoanAuthor': statement_of_responsibility,
      'ISSN': isbn_number.join(' / ')

    }
  end

  def illiad_request_params_journal_variable
    {
      'genre': 'TRLNjournal',
      'form': '22',
      'PhotoJournalTitle': fetch(TrlnArgon::Fields::TITLE_MAIN, ''),
      'ISSN': issn.join(' / ')
    }  
  end

  def item_url_absolute
    [
      TrlnArgon::Engine.configuration.root_url.chomp('/'),
      Rails.application.routes.url_helpers\
           .trln_solr_document_url(self, only_path: true)
    ].join
  end
end