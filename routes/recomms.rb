
get '/recomms/:steamid' do
  begin
    json getRecomms(params[:steamid])
  rescue RuntimeError => e
    { "error" => true, "message" => e }.to_json
  rescue IOError => e
    { "error" => true, "message" => e }.to_json
  end
end

get '/private' do
  haml :private
end

get '/connection' do
  haml :connection
end

