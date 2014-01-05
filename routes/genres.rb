require 'will_paginate'
require 'will_paginate/data_mapper'

get '/genres' do
  page = params[:page] || 1
  results = [] 
  genres = Genre.paginate(:order => [:id.asc],  :page => page, :per_page => 10)
  genres.each do |genre|
    games = genre.games.
      paginate(:app_type => 'game', :order => [:total_playtime.desc],  
               :page => 1, :per_page => 4)
    obj = { 'name' => genre.name, 'id' => genre.id, 'games' => games }
    results << obj
  end
  results.to_json 
end

get '/genres/size' do
  genreCount = Genre.count
  pageCount = (genreCount / 10.0).ceil.to_i
  hash = {
    "itemCount" => genreCount,
    "pageCount" => pageCount
  }
  hash.to_json
end

get '/genres/:genre' do
  page = params[:page] || 1
  order_list = [:appid.asc]
  if params[:order]
    order_list = [ params[:order].to_sym.desc, :appid.asc ]
  end
  genre = Genre.get(params[:genre])
  games = genre.games.paginate(:app_type => 'game', :order => order_list,  :page => page, :per_page => 30)
  results = { 'id' => genre.id, 'name' => genre.name }
  results['games'] = games 
  results.to_json
end

get '/genres/:genre/size' do
  genre = Genre.get(params[:genre])
  genreCount = genre.games.count
  pageCount = (genreCount / 30).ceil.to_i
  hash = {
    "gameCount" => genreCount,
    "pageCount" => pageCount
  }
  hash.to_json
end

