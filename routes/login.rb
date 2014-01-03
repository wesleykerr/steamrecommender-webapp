# Session needs to be before Rack::OpenID
use Rack::Session::Cookie

require 'rack/openid'
use Rack::OpenID

get '/steamid' do
  haml :steamid
end

get '/reset' do
  session[:steamid] = nil
  session[:redirectTo] = nil
  redirect to('/steamid')
end

get '/login' do
  if resp = request.env["rack.openid.response"]
    if resp.status == :success
      puts "Welcome: #{resp.display_identifier}"
      tokens = resp.display_identifier.split('/')
      id = tokens[tokens.length-1]
      session[:steamid] = id
      if session[:redirectTo]
        redirect to(session[:redirectTo])
      end
      redirect to('/profile')
    else
      "Error: #{resp.status}"
      redirect "/steamid"
    end
  else
    headers 'WWW-Authenticate' => Rack::OpenID.build_header(
      :identifier => 'http://steamcommunity.com/openid'
    )
    throw :halt, [401, 'got openid?']
  end
end


