
get '/recomms' do
  unless session[:steamid]
    session[:redirectTo] = '/recomms'
    redirect to('/steamid')
  end
  @page = 1
  @page = params[:page].to_i if params[:page]
  @steamid = session[:steamid]
  begin
    @not_played,@not_owned = get_recomms(@steamid, @page)
    haml :recomms
  rescue RuntimeError
    redirect to('/private')
  rescue IOError
    redirect to('/connection')
  end
  "You did it"
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

