
get '/recomms/:steamid' do
  begin
    json getRecomms(params[:steamid])
  rescue RuntimeError => e
    { "error" => true, "id" => 1, "message" => e }.to_json
  rescue IOError => e
    { "error" => true, "id" => 2, "message" => e }.to_json
  end
end

