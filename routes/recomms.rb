
get '/recomms' do
  unless session[:steamid]
    session[:redirectTo] = '/recomms'
    redirect to('/steamid')
  end
  begin
    json getRecomms(session[:steamid])
  rescue RuntimeError
    redirect to('/private')
  rescue IOError => e
    logger.info { "ERROR -> #{e}" }
    redirect to('/connection')
  end
end

get '/recomms_submit' do
  session[:steamid] = params[:steamid]
  redirect to('/profile')
end

get '/recomms/:steamid' do
  @page = 1
  @page = params[:page].to_i if params[:page]
  @steamid = params[:steamid]
  session[:steamid] = @steamid
  @not_played,@not_owned = get_recomms(@steamid, @page)
  haml :recomms
end

get '/private' do
  haml :private
end

get '/connection' do
  haml :connection
end

