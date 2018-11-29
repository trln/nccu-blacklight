# frozen_string_literal: true

require 'rails_helper'

describe SolrDocument do
  

  describe 'nccu_requestable?' do
    context 'when item is in NCCU collection and at the library' do
      let(:solr_document) do
        described_class.new(
          id: 'NCCU012345678',
          access_type_a: '["At the Library","Online"]'
        )
      end

      before do
        allow(solr_document).to receive(:record_owner).and_return('nccu')
      end

      it 'is requestable' do
        expect(solr_document.nccu_requestable?).to be true
      end
    end

    context 'when item is at the library, but not in NCCU collection' do
      let(:solr_document) do
        described_class.new(
          id: 'UNC012345678',
          access_type_a: '["At the Library"]'
        )
      end

      before do
        allow(solr_document).to receive(:record_owner).and_return('unc')
      end

      it 'is not requestable' do
        expect(solr_document.nccu_requestable?).to be false
      end
    end

    context 'when item is in NCCU collection, but online-only' do
      let(:solr_document) do
        described_class.new(
          id: 'NCCU012345678',
          access_type_a: '["Online"]'
        )
      end

      before do
        allow(solr_document).to receive(:record_owner).and_return('nccu')
      end

      it 'is not requestable' do
        expect(solr_document.nccu_requestable?).to be false
      end
    end
  end

  describe 'trln_requestable?' do
    context 'when item is at partner institution and at the library' do
      let(:solr_document) do
        described_class.new(
          id: 'UNC012345678',
          access_type_a: '["At the Library","Online"]'
        )
      end

      before do
        allow(solr_document).to receive(:record_owner).and_return('unc')
      end

      it 'is requestable' do
        expect(solr_document.trln_requestable?).to be true
      end
    end

    context 'when item is at partner institution, but online-only' do
      let(:solr_document) do
        described_class.new(
          id: 'UNC012345678',
          access_type_a: '["Online"]'
        )
      end

      before do
        allow(solr_document).to receive(:record_owner).and_return('unc')
      end

      it 'is not requestable' do
        expect(solr_document.trln_requestable?).to be false
      end
    end
  end

  describe '#nccu_item?' do
    describe 'illiad_request_url_default' do
      before do
        allow(NccuBlacklight).to receive(:illiad_main_base_url)
          .and_return(
            'https://nccu.illiad.oclc.org/illiad/ncx/illiad.dll'
          )

        allow(solr_document).to receive(:illiad_request_params)\
          .and_return(
            'LoanAuthor=Art+Chansky&LoanTitle=Blue+blood'\
            '&Value=GenericRequestTRLNLoan&genre=TRLNbook'
          )
      end

      let(:solr_document) do
        described_class.new(
          id: 'NCCU012345678'
        )
      end

      it 'returns the full URL to request the item from TRLN at NCCU' do
        expect(solr_document.illiad_request_url_default).to eq(
          'https://nccu.illiad.oclc.org/illiad/ncx/illiad.dll?LoanAuthor=Art+Chansky&LoanTitle=Blue+blood'\
          '&Value=GenericRequestTRLNLoan&genre=TRLNbook'
        )
      end
    end

    describe 'illiad_request_params' do
      let(:solr_document) do
        described_class.new(
          id: 'NCCU003485622'
        )
      end

      before do
        allow(solr_document).to receive(:illiad_request_params_fixed)\
          .and_return(
            'Value': 'GenericRequestTRLNLoan',
            'genre': 'TRLNbook'
          )
        allow(solr_document).to receive(:illiad_request_params_book_variable)\
          .and_return(
            'Location': 'https://find.library.duke.edu/trln/DUKE003485622',
            'LoanTitle': 'Blue blood',
            'ESPNumber': '505249141',
            'ISSN': '9780134276717 / 013427671X',
            'LoanEdition': '1st ed.',
            'LoanPublisher': 'Boston',
            'LoanAuthor': 'Art Chansky'
          )
      end

      # rubocop:disable RSpec/ExampleLength
      it 'returns the combined parameters as URL query string' do
        expect(solr_document.illiad_request_params).to eq(
          'ESPNumber=505249141&ISSN=9780134276717+%2F+013427671X'\
          '&LoanAuthor=Art+Chansky&LoanEdition=1st+ed.&LoanPublisher=Boston'\
          '&LoanTitle=Blue+blood'\
          '&Location=https%3A%2F%2Ffind.library.duke.edu%2F'\
          'trln%2FDUKE003485622'\
          '&Value=GenericRequestTRLNLoan&genre=TRLNbook'
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end

    describe 'illiad_request_params' do
      let(:solr_document) do
        described_class.new(
          id: 'NCSU295414',
          resource_type_a: ["Journal, Magazine, or Periodical"]
        )
      end

      before do
        allow(solr_document).to receive(:illiad_request_params_fixed)\
          .and_return(
            'Value': 'GenericRequestTRLNLoan',
            'genre': 'TRLNjournal'
          )
        allow(solr_document).to receive(:illiad_request_params_journal_variable)\
          .and_return(
            'ESPNumber': '505249141',
            'PhotoJournalTitle': 'Nature methods.',
            'ISSN': '0036-8075 / 0096-3771'
          )
      end

      # rubocop:disable RSpec/ExampleLength
      it 'returns the combined parameters as URL query string' do
        expect(solr_document.illiad_request_params).to eq(
          'ESPNumber=505249141&ISSN=0036-8075+%2F+0096-3771'\
          '&PhotoJournalTitle=Nature+methods.&Value=GenericRequestTRLNLoan&genre=TRLNjournal'
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end