require 'httparty'
require 'nokogiri'
require 'open-uri'
require 'logger'
require 'damerau-levenshtein'

require 'uri'
require 'net/http'

log = Logger.new(STDOUT)
log.level = Logger::DEBUG


class GameLinker

  def initialize()
    @log = Logger.new(STDOUT)
    @log.level = Logger::DEBUG

    @gb_key = "1bcdfb88180202845adab96300ff82e7ffefe0e9"
    @gb_api = "http://www.giantbomb.com/api"

    @steam = URI.parse("http://store.steampowered.com/")

    #@db = Database.new("localhost", "root")
  end

  def run()
    good = File.open("/Users/wkerr/development/game-linker/data/metacritic.tsv", "w")
    bad = File.open("/Users/wkerr/development/game-linker/data/missing.tsv", "w")

    @steam = URI.parse("http://store.steampowered.com/")

    #@db = Database.new("localhost", "root")
  end

  def run()
    good = File.open("/Users/wkerr/development/game-linker/data/metacritic.tsv", "w")
    bad = File.open("/Users/wkerr/development/game-linker/data/missing.tsv", "w")
    File.open("/Users/wkerr/development/game-linker/data/apps.tsv", "r") do |fd|
      fd.each() do |line|
        line = line.chomp
        tokens = line.split("\t")
        meta = tokens[1].include?("Trailer") ? nil : metacritic(tokens[0]) 
        if meta
          good.puts "#{line}\t#{meta}"
          good.fsync
          @log.debug { "App: #{tokens[0]} #{meta}" } 
        else
          bad.puts "#{line}" 
          bad.fsync
        end
        sleep 5
      end
    end

    good.close
    bad.close
  end

  def get_steam_url(appid)
    req = Net::HTTP.new(@steam.host, @steam.port)
    res = req.request_head("/app/#{appid}")
    if res.code == "200"
      body = req.get("/app/#{appid}")
      return "#{@steam.to_s}/app/#{appid}" unless body.body.include?('This item is currently unavailable in your region')
    end 
    return nil
  end

  def get_steam_genres(url)
    doc = Nokogiri::HTML(open(URI::encode(url)))
    results = doc.css('.details_block > a')
    genres = results.map do |link|
      if link['href'].include? 'genre'
        link.content
      else
        nil
      end
    end.compact! 
  end

  def search_giantbomb(name)
    encoded = URI::encode(name)
    params = "resources=game&field_list=id,name,site_detail_url"
    uri = URI("#{@gb_api}/search/?api_key=#{@gb_key}&format=json&query=#{encoded}&#{params}")
    @log.debug { "URI: #{uri} " }
    results = Net::HTTP.get(uri)
    result_hash = JSON.parse(results)

    raise "bad results #{results}" unless result_hash['error'] == "OK"
    games = result_hash['results']
    games.each do |game_hash|
      title = game_hash['name']
      game_hash['score'] = DamerauLevenshtein.distance(name, title) / [name.size, title.size].max.to_r
    end 
    games.sort! do |a,b|
      a['score'] <=> b['score']
    end
    games
  end
    
  def get_giantbomb_genres(game_id)
    params = "field_list=genres"
    uri = URI("#{@gb_api}/game/#{game_id}/?api_key=#{@gb_key}&format=json&#{params}")
    @log.debug { "URI: #{uri} " }
    results = Net::HTTP.get(uri)
    result_hash = JSON.parse(results)

    raise "bad results #{results}" unless result_hash['error'] == "OK"
    if result_hash['results'].size > 0
      genres = result_hash['results']['genres']
      return genres.map do |genre|
        genre['name']
      end
    end
    return []
  end

  def search_metacritic(name)
    clean_name = name.gsub(':', '').gsub('-', ' ').gsub(' ', '+')
    search_url = 'http://www.metacritic.com/search/game/'
    url = "#{search_url}#{clean_name}/results"
    @log.debug { "URL: #{url}" }
    doc = Nokogiri::HTML(open(URI::encode(url)))
    results = doc.css('ul.search_results > li')
    titles = results.map do |result|
      # make sure that the game is for PC and not ps2
      platform_obj = result.css('.platform')[0]
      next if platform_obj.content.lstrip.rstrip != 'PC'

      object = result.css('h3.product_title > a')[0]
      url = object['href']
      title = object.content.lstrip.rstrip
      @log.debug { "Name: #{name}:#{name.size} Title: #{title}:#{title.size}" }
      @log.debug { "  Raw Distance: #{DamerauLevenshtein.distance(name,title)}, #{[name.size,title.size].max}" } 
      score = DamerauLevenshtein.distance(name, title) / [name.size, title.size].max.to_f
      [url, title, score]
    end.compact!
    titles.sort! do |a,b|
      a[2] <=> b[2]
    end
    return titles
  end

  def metacritic(appid)
    doc = Nokogiri::HTML(open("#{@steam}#{appid}"))
    metalinks = doc.css('#game_area_metalink a')
    if metalinks.size == 1 
      metalinks[0]['href']
    elsif metalinks.size == 0
      @log.info { "No metalink information for #{appid}" }
      nil
    else 
      @log.warn { "Multiple metalink rows for #{appid}" }
      nil
    end
  end
end


