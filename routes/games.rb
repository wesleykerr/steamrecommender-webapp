require 'will_paginate'
require 'will_paginate/data_mapper'

get '/games/size' do
  gameCount = Game.count
  pageCount = (Game.count / 30).ceil.to_i
  hash = {
    "gameCount" => gameCount,
    "pageCount" => pageCount
  }
  hash.to_json
end

get '/games' do
  page = params[:page] || 1
  order_list = [:appid.asc]
  if params[:order]
    order_list = [ params[:order].to_sym.desc, :appid.asc ]
  end
  @games = Game.paginate(:app_type => 'game', :order => order_list, 
                         :page => page, :per_page => 30)
  @games.to_json
end

get '/games/:game' do
  game = Game.get(params[:game])
  genres = game.genres.map { |genre| genre.name }.join(", ")
  hash = JSON.parse(game.to_json)
  hash['genres'] = genres
  hash.to_json
end


