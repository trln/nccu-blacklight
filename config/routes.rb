Rails.application.routes.draw do
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  mount Blacklight::Engine => '/'
  mount TrlnArgon::Engine => '/'

  root to: "trln#index"

  concern :searchable, Blacklight::Routes::Searchable.new

  resource :trln, only: [:index], as: 'trln', path: '/trln', controller: 'trln' do
    concerns :searchable
    concerns :range_searchable
  end



  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
  end

  # devise_for :users
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :trln_solr_documents, only: [:show], path: '/trln', controller: 'trln' do
    concerns :exportable
  end

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  resource :map_location, only: [:show], as: 'map_location', path: '/map_location', controller: 'map_location'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end