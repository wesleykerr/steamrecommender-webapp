

get '/profile' do
  unless session[:steamid]
    session[:returnTo] = '/profile'
    redirect to('/steamid')
  end
  haml :profile
end

