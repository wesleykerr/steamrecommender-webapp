require 'will_paginate'
require 'will_paginate/data_mapper'

get '/genres' do
  page = params[:page] || 1
  @genres = Genre.paginate(:order => [:id.asc],  :page => page, :per_page => 30)
  haml :genres
end

get '/genres/:genre' do
  page = params[:page] || 1
  order_list = [:appid.asc]
  if params[:order]
    order_list = [ params[:order].to_sym.desc, :appid.asc ]
  end
  @genre = Genre.get(params[:genre])
  @title = @genre.name
  @games = @genre.games.paginate(:app_type => 'game', :order => order_list,  :page => page, :per_page => 30)
  haml :genre
end


