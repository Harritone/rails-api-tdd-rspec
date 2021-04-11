require 'rails_helper'

RSpec.describe "/articles routes" do
  it "routes to articles#index" do
    # expect(get '/articles').to route_to(controller: 'articles', action: 'index')
    expect(get '/articles').to route_to('articles#index')
    expect(get '/articles?page[number]=3').to route_to('articles#index', page: { 'number' => '3' })
  end

  it "routes to article#show" do
    expect(get '/articles/1').to route_to('articles#show', id: '1')
  end

  it 'should route to articles#create' do
    expect(post '/articles').to route_to('articles#create')
  end

  it 'should route to article#update' do
    expect(put 'articles/1').to route_to('articles#update', id: '1')
    expect(patch 'articles/1').to route_to('articles#update', id: '1')
  end
  
end
