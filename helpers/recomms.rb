require 'narray'
require 'json'
require 'uri'
require 'net/http'

helpers do
  def merge(obj_array, obj_map) 
    obj_array.each do |hash|
      game = obj_map[hash['appid']]
      hash['title'] = game[:title]
      hash['steam_url'] = game[:steam_url]
      hash['steam_img_url'] = game[:steam_img_url]
    end 
  end

  # generate the recommendations
  # @param [Number] the steam id we are looking up
  # @param [Number] the maximum number of recomms
  def get_recomms(steamid, num_recomms=100)
    data = query_steam(steamid)
    owned = []
    played = []
    data['games'].each do |game_stats|
      owned << game_stats['appid']
      forever = game_stats['playtime_forever']
      played << game_stats['appid'] if (forever && forever >= 30)
    end
    columns = Model.all(:appid => played + [-1])
    
    result = @matrix * player_vector
    not_played_scores = []
    not_owned_scores = []
    @items.each_with_index do |item,idx|
      item_hash = {}
      item_hash['appid'] = item
      item_hash['score'] = result[idx]
      if owned_set.include?(item) && !played_set.include?(item)
        not_played_scores << item_hash
      end

      unless owned_set.include?(item)
        not_owned_scores << item_hash
      end
    end
    not_played_scores.sort! { |x,y| y['score'] <=> x['score'] }
    not_owned_scores.sort! { |x,y| y['score'] <=> x['score'] }
    [not_played_scores[0..num_recomms-1],not_owned_scores[0..num_recomms-1]]
  end

  # generate or find the recommendations for a steamid
  # returns the subset within the page.
  # @param [Number] the steamid we are looking up
  # @param [Number] the page that we are on
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

  
class MatrixRecomms < Recomms

  def initialize(config_obj)
    super(config_obj)
    matrix_file = "#{File.expand_path('.')}/../config/heats.csv" 
    # TODO: uncomment when we are ready to start computing scores.
    #load_matrix(matrix_file)
  end

  def get_recomms(steamid, num_recomms=100, session=nil)
    data = owned_games(steamid)
    player_vector,owned_set,played_set = parse_data(data)
    
    result = @matrix * player_vector
    not_played_scores = []
    not_owned_scores = []
    @items.each_with_index do |item,idx|
      item_hash = {}
      item_hash['appid'] = item
      item_hash['score'] = result[idx]
      if owned_set.include?(item) && !played_set.include?(item)
        not_played_scores << item_hash
      end

      unless owned_set.include?(item)
        not_owned_scores << item_hash
      end
    end
    not_played_scores.sort! { |x,y| y['score'] <=> x['score'] }
    not_owned_scores.sort! { |x,y| y['score'] <=> x['score'] }
    [not_played_scores[0..num_recomms-1],not_owned_scores[0..num_recomms-1]]
  end

  private
  def load_matrix(matrix_file)
    @log.info { "loading matrix beginning" } 
    File.open(matrix_file, 'r') do |file_io|
      @items = file_io.readline().split(',')
      @items.shift
      @items = @items.map { |item| item.to_i }
      
      @matrix = NMatrix.float(@items.count, @items.count)
      file_io.each_line do |line|
        scores = line.split(',')
        scores.shift
        scores.each_with_index do |score,idx| 
          @matrix[ idx, file_io.lineno-2 ] = score.to_f
        end
      end
    end
    @log.info { "loading matrix finished" }
  end

  def parse_data(data)
    player_vector = NVector.float(@matrix.sizes[0])
    owned_set = Set.new
    played_set = Set.new
    data['games'].each do |game_stats|
      owned_set.add(game_stats['appid'])
      forever = game_stats['playtime_forever']
      if forever && forever >= 30
        idx = @items.find_index(game_stats['appid'])
        player_vector[idx] = 1 
        played_set.add(game_stats['appid'])
      end
    end
    [player_vector,owned_set,played_set]
  end
end

