

get '/profile/:steamid' do
  begin
    details = getProfile(params[:steamid])
    details.sort! { |x,y| y['playtime_forever'] <=> x['playtime_forever'] }
    json details
  rescue RuntimeError => e
    { "error" => true, "id" => 1, "message" => e }.to_json
  rescue IOError => e
    { "error" => true, "id" => 2, "message" => e }.to_json
  end
end


