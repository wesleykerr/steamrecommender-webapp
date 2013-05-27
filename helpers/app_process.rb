
log = Logger.new(STDOUT)
log.level = Logger::DEBUG

linker = GameLinker.new
db = Database.new("localhost", "root")
data = []

File.open('data/apps.tsv', 'r') do |input_io|
  input_io.each do |line|
    columns = line.chomp.split("\t")
    appid = columns[0]
    steam_url = linker.get_steam_url(appid)
    log.debug { "Checking #{columns[1]} url #{steam_url}" }
    if steam_url != nil 
      steam_genres = linker.get_steam_genres(steam_url)
      log.debug { "Found steam game #{columns[1]} with genres #{steam_genres}" }
      update_steam(db, appid, steam_genres)
      giantbomb_candidates = linker.search_giantbomb(columns[1])
      log.debug { "..........candidates - #{giantbomb_candidates.map { |game| "#{game['name']} s:#{game['score']}" } } " }
      if giantbomb_candidates && giantbomb_candidates.size > 0
        ## assume that the first one is good....
        gb_game = giantbomb_candidates[0]
        gb_genres = linker.get_giantbomb_genres(gb_game['id'])
        update_giantbomb(db, appid, gb_game['id'], gb_genres, gb_game['site_detail_url'])
        log.debug { "...giantbomb details #{gb_game['name']} with genres #{gb_genres}" }
      end
    end
  end
end

def update_steam(db, appid, genres) 
  if genres
    str = db.escape(genres.join(','))
    sql = "update game_recommender.games set steam_genres = '#{str}', app_type = 'game' where appid = #{appid}"
    db.update(sql)
  end
end

def update_giantbomb(db, appid, gb_id, gb_genres, gb_site)
  str = db.escape(gb_genres.join(','))
  sql = "update game_recommender.games set giantbomb_id = #{gb_id}, giantbomb_site = '#{gb_site}', giantbomb_genres = '#{str}' where appid = #{appid}"
  db.update(sql)
end

data
