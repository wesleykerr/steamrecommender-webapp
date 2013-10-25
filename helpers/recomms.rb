require 'narray'
require 'json'
require 'uri'
require 'net/http'
  
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

