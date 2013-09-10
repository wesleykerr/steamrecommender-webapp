
helpers do

  def merge(obj_array, obj_map) 
    obj_array.each do |hash|
      game = obj_map[hash['appid']]
      hash['title'] = game[:title]
      hash['steam_url'] = game[:steam_url]
      hash['steam_img_url'] = game[:steam_img_url]
    end 
  end

  def get_recomms(steamid, page_number=1)
    # 4 hours back
    s_time = Time.now
    min_date = DateTime.now - Rational(4, 24)
    audit_records = AuditRecomm.all(:steamid => steamid, :order => [ :create_datetime.desc ])
    json_obj = { }
    if (audit_records && audit_records.length > 0 && audit_records.first[:create_datetime] > min_date)
      audit_recomm = audit_records.first
      json_obj = audit_recomm[:recomms]
      e_time = Time.now
      logger.info { "get_recomms audit record #{(e_time.to_ms - s_time.to_ms)}" } 
    else
      not_played,not_owned = @@matrix_recomms.get_recomms(steamid)
      json_obj = { "not_played" => not_played, "not_owned" => not_owned, "pages" => [] }
      e_time = Time.now
      logger.info { "get_recomms matrix multiplication #{(e_time.to_ms - s_time.to_ms)}" } 
    end
   
    start_index = (page_number-1)*10
    sub_np = json_obj["not_played"][start_index..start_index+9] || []
    sub_no = json_obj["not_owned"][start_index..start_index+9]
    unless (json_obj["pages"].include? page_number) 
      games_map = {}
      s_time = Time.now
      ids = sub_np.map { |x| x['appid'] } .concat(sub_no.map { |x| x['appid'] })
      games = Game.all(:fields => [:appid,:title,:steam_url,:steam_img_url], :appid => ids ) 
      games.each { |game| games_map[game.appid] = game }
      merge(sub_np, games_map)
      merge(sub_no, games_map)
      json_obj["pages"] << page_number
      e_time = Time.now
      logger.info { "get_recomms gathered games #{(e_time.to_ms - s_time.to_ms)}" } 
    end

    if (audit_recomm)
      audit_recomm[:recomms] = json_obj.to_json
      audit_recomm.save
    else
      AuditRecomm.create(:steamid => steamid, 
                         :create_datetime => DateTime.now, 
                         :recomms => json_obj.to_json) 
    end

    [sub_np,sub_no]
  end
end


get '/recomms' do
  haml :recomms
end

get '/recomms_submit' do
  @page = 1
  @page = params[:page].to_i if params[:page]
  @steamid = params[:steamid]
  @not_played,@not_owned = get_recomms(@steamid, @page)
  haml :recomms_personal
end

get '/recomms/:steamid' do
  @page = 1
  @page = params[:page].to_i if params[:page]
  @steamid = params[:steamid]
  @not_played,@not_owned = get_recomms(@steamid, @page)
  haml :recomms_personal
end



