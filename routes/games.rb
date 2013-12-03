require 'will_paginate'
require 'will_paginate/data_mapper'

get '/games' do
  page = params[:page] || 1
  order_list = [:appid.asc]
  if params[:order]
    order_list = [ params[:order].to_sym.desc, :appid.asc ]
  end
  games = Game.paginate(:app_type => 'game', :order => order_list,  :page => page, :per_page => 30)
  games.to_json
end

get '/games/:game' do
  game = Game.get(params[:game])
  game.to_json
end


