require 'will_paginate'
require 'will_paginate/data_mapper'

get '/games' do
  page = params[:page] || 1
  @games = Game.paginate(:app_type => 'game', :order => [:appid.asc],  :page => page, :per_page => 30)
  haml :games
end

get '/games/:game' do
  @game = Game.get(params[:game])
  @title = @game.title
  haml :game
end


