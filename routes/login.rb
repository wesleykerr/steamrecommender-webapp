# Session needs to be before Rack::OpenID
use Rack::Session::Cookie

require 'rack/openid'
use Rack::OpenID

get '/login' do
  if resp = request.env["rack.openid.response"]
    if resp.status == :success
      puts "Welcome: #{resp.display_identifier}"
      tokens = resp.display_identifier.split('/')
      id = tokens[tokens.length-1]
      redirect "/recomms/#{id}"
    else
      "Error: #{resp.status}"
    end
  else
    headers 'WWW-Authenticate' => Rack::OpenID.build_header(
      :identifier => 'http://steamcommunity.com/openid'
    )
    throw :halt, [401, 'got openid?']
  end
end


