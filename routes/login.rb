# Session needs to be before Rack::OpenID
use Rack::Session::Cookie

require 'rack/openid'
use Rack::OpenID

get '/login' do
  if resp = request.env["rack.openid.response"]
    if resp.status == :success
      puts "Welcome: #{resp.display_identifier}"
      logger.info { "welcome [#{resp.display_identifier}]" }
      tokens = resp.display_identifier.split('/')
      id = tokens[tokens.length-1]
      redirect to("index.html#/profile/#{id}")
    else
      "Error: #{resp.status}"
      redirect "#/steamid"
    end
  else
    headers 'WWW-Authenticate' => Rack::OpenID.build_header(
      :identifier => 'http://steamcommunity.com/openid'
    )
    throw :halt, [401, 'got openid?']
  end
end

get '/resolve/:vanity' do
  begin
    details = getSteamId(params[:vanity])
    json details
  rescue RuntimeError => e
    { "error" => true, "id" => 1, "message" => e}.to_json
  rescue IOError => e
    { "error" => true, "id" => 2, "message" => e}.to_json
  end
end

get '/summary/:steamId' do
  begin
    details = getPlayerSummary(params[:steamId])
    json details
  rescue RuntimeError => e
    { "error" => true, "id" => 1, "message" => e}.to_json
  rescue IOError => e
    { "error" => true, "id" => 2, "message" => e}.to_json
  end
end
