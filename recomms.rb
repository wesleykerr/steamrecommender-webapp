require 'narray'
require 'json'
require 'uri'
require 'net/http'
require 'logger'
  

class Recomms
 
  def initialize
    @log = Logger.new(STDOUT)
    @log.level = Logger::DEBUG
    @config_obj = YAML::load_file( "#{File.expand_path('.')}/../config/steamrecommender.yml" )
  end 

  def owned_games(steamid)
    # TODO: add retry logic
    steam_host="api.steampowered.com"
    steam_path="/IPlayerService/GetOwnedGames/v0001/"
    steam_key=@config_obj['steam_key']
    @log.debug { "key: #{steam_key}" }
    steam_params='include_played_free_games=1'
    uri = URI("http://#{steam_host}#{steam_path}?key=#{steam_key}&steamid=#{steamid}&#{steam_params}")
    document = Net::HTTP.get(uri)
    data = JSON.parse(document)['response']

    # save an audit record
    audit = Audit.create(
      :steamid => steamid,
      :json => data,
      :create_datetime => DateTime.now
    )
    @log.error("Failed to create audit record #{steamid}") unless audit.saved?
    data
  end

end

class CosineRecomms < Recomms

  def initialize
    super
    load_cosine_matrix
  end

  def get_recomms(steamid, num_recomms=100, session=nil)
    data = owned_games(steamid)
    player_vector,owned_set,played_set = parse_data(data)
    
    result = @cosine_matrix * player_vector
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
  def load_cosine_matrix
    @log.info { "loading cosine matrix" } 
    cosine_file = "#{File.expand_path('.')}/../config/item_item.csv" 
    File.open(cosine_file, 'r') do |file_io|
      @items = file_io.readline().split(',')
      @items.shift
      @items = @items.map { |item| item.to_i }
      
      @cosine_matrix = NMatrix.float(@items.count, @items.count)
      file_io.each_line do |line|
        scores = line.split(',')
        scores.shift
        scores.each_with_index do |score,idx| 
          @cosine_matrix[ file_io.lineno-2, idx ]  = score.to_f
        end
      end
    end
    @log.info { "loading cosine matrix finished" }
  end

  def parse_data(data)
    player_vector = NVector.float(@cosine_matrix.sizes[0])
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

