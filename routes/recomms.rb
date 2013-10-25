
get '/recomms' do
  haml :recomms
end

get '/recomms_submit' do
  @page = 1
  @page = params[:page].to_i if params[:page]
  @steamid = params[:steamid]
  #@not_played,@not_owned = get_recomms(@steamid, @page)
  haml :recomms_personal
end

get '/recomms/:steamid' do
  @page = 1
  @page = params[:page].to_i if params[:page]
  @steamid = params[:steamid]
  #@not_played,@not_owned = get_recomms(@steamid, @page)
  haml :recomms_personal
end




