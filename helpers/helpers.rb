require 'narray'
require 'json'
require 'uri'
require 'net/http'

helpers do

  def google_ad() 
    '<script async src="http://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
    <!-- bottom-banner -->
    <ins class="adsbygoogle"
     style="display:inline-block;width:728px;height:90px"
          data-ad-client="ca-pub-5053630439831931"
               data-ad-slot="3313792403"></ins>
               <script>
               (adsbygoogle = window.adsbygoogle || []).push({});
               </script>'
  end

  # generate the rating for this game based on the different
  # quantiles provided.
  def getRating(playtime, q25, q50, q75)
    return 0 unless playtime && playtime > 0 
    
    hoursPlayed = [playtime / 60.0, q75].min
    pctScore = hoursPlayed / q75.to_f;
    return 1 + (pctScore * 5)
  end

  # retrieve related recommendations for the given appid
  # @param [Number] the appid to lookup
  # @param [Number] the number of recommendations
  # @return [Array] recommended items
  def getRecommIdsAndScores(played, notPlayed, nrecs)
    headers = Model.get(1, -1)
    headers = headers.model_column.split(",").map { |x| x.to_i } 

    modelMatrix = NMatrix.float(played.count, headers.count)
    models = Model.all(:model_id => 1, :appid => played, :order => [:appid.asc])
    models.each_with_index do |model,col|
      model.model_column.split(",").each_with_index do |x,row|
        modelMatrix[col, row] = x.to_f
      end
    end
    vector = NVector.float(played.count)
    vector.fill!(1)
    
    resultVector = modelMatrix * vector
    recommsNew = []
    recommsNotPlayed = []
    headers.each_with_index do |appid,idx|
      unless played.include?(appid) 
        hash = { 'appid' => appid, 'score' => resultVector[idx] }
        if notPlayed.include?(appid)
          recommsNotPlayed << hash
        else
          recommsNew << hash
        end
      end
    end
    newRecomms = recommsNew.sort! { |x,y| y['score'] <=> x['score'] }.slice(0, nrecs)
    ownedRecomms = recommsNotPlayed.sort! { |x,y| y['score'] <=> x['score'] }.slice(0, nrecs)
    { "recommsNew" => populateGameData(newRecomms), 
      "recommsOwned" => populateGameData(ownedRecomms) } 
  end

  # compute all of the recommendations for a user
  # and gather them from the cache if they already exist
  # @param [String] the steam id
  # @return the recommendations
  def getRecomms(steamid)
    cacheDetails = AuditRecomm.getAuditRecord(steamid)
    return cacheDetails if cacheDetails

    steamDetails = getSteamDetails(steamid)
    played,notPlayed = parsePlayerData(steamDetails)
    recomms = getRecommIdsAndScores(played, notPlayed, 100)
    audit = AuditRecomm.create(
      :steamid => steamid,
      :recomms => recomms,
      :create_datetime => DateTime.now
    )
    unless audit.saved?
      logger.info(" RECOMMS: #{recomms.to_s.length}")
      logger.error("Failed to create audit recomms record #{steamid}") 
      audit.errors.each do |e| 
        logger.info { "error #{e}" }
      end
    end
    recomms
  end

  # iterate through the array and populate each game with
  # details from the game database.
  # @param [Array] the arry of game hash details
  # @return [Array] the array of game ids with additional details
  def populateGameData(array) 
    gameMap = {}
    ids = array.collect do |steamGame| 
      id = steamGame['appid']
      gameMap[id] = steamGame
      id
    end
    games = Game.all(:fields => [:appid,:title,:steam_url,:steam_img_url], :appid => ids ) 
    games.each do |game|
      hash = gameMap[game.appid]
      hash['title'] = game.title
      hash['steam_url'] = game.steam_url
      hash['steam_img_url'] = game.steam_img_url
    end
    gameMap.values
  end
 
  # go over all of the player data and find the games 
  # played so that we can pull build the correct
  # records.
  def parsePlayerData(data)
    played = Set.new
    notPlayed = Set.new
    data['games'].each do |game_stats|
      appid = game_stats['appid']
      forever = game_stats['playtime_forever']
      if forever && forever >= 30
        played.add(appid)
      else
        notPlayed.add(appid)
      end
    end
    [played, notPlayed]
  end

  # generate the profile data for the profile endpoint.
  # If present in the cache, return it. Otherwise
  # generate it.
  def getProfile(steamid)
    cacheDetails = AuditProfile.getAuditRecord(steamid)
    return cacheDetails if cacheDetails

    # the details are missing so we need to query it
    steamDetails = getSteamDetails(steamid)
    logger.info { "Steam Details #{steamDetails.to_json}" } 
    gameMap = {}
    ids = steamDetails['games'].map do |steamGame| 
      id = steamGame['appid']
      gameMap[id] = steamGame
      id
    end
    fields = [
      :appid, :title, :steam_url, :steam_img_url,
      :total_q25, :total_median, :total_q75, 
      :recomms
    ]
    games = Game.all(:fields => fields, :appid => ids ) 
    games.each do |game|
      hash = gameMap[game.appid]
      hash['title'] = game.title
      hash['steam_url'] = game.steam_url
      hash['steam_img_url'] = game.steam_img_url
      hash['recomms'] = game.recomms
      hash['total_median'] = game.total_median.to_f
      hash['rating'] = getRating(
        hash['playtime_forever'], game.total_q25, game.total_median, game.total_q75
      )
      hash['playtime'] = hash['playtime_forever'] / 60.0 if hash['playtime_forever']
    end
    
    audit = AuditProfile.create(:steamid => steamid,
                                :profile => gameMap.values,
                                :create_datetime => DateTime.now
    )
    logger.error("failed to create audit profile record #{steamid}") unless audit.saved?
    gameMap.values
  end 

  # This method sends a query to steam to get the most recent
  # statistics about a players gaming habits.
  # @param [String] steamid
  def getSteamDetails(steamid)
    json_obj = Audit.getAuditRecord(steamid)
    return json_obj if json_obj
    
    logger.info { "GET IPlayerService/GetOwnedGames/v0001/#{steamid}" } 
    host="api.steampowered.com"
    path="/IPlayerService/GetOwnedGames/v0001/"
    steam_key=@@config_obj['steam_key']
    params='include_played_free_games=1'
    uri = URI("http://#{host}#{path}?key=#{steam_key}&steamid=#{steamid}&#{params}")
    logger.info { "GET #{uri}" } 
    
    count = 0 
    success = false
    begin
      begin
        document = Net::HTTP.get(uri)
        data = JSON.parse(document)['response']
        success = true
      rescue JSON::ParserError => e
        logger.debug { "Failed to parse response document #{e}" }
        success = false
        count += 1
      end
    end while !success && count < 5

    unless success
      logger.error { "Failed to connect to steam after n tries, so giving up" }
      raise IOError, "Steam connection error!" 
    end
    raise RuntimeError, 'Private Steam Profile!' if data.size == 0
    
    audit = Audit.create(
      :steamid => steamid,
      :json => data,
      :create_datetime => DateTime.now
    )
    logger.error("Failed to create audit record #{steamid}") unless audit.saved?
    data
  end
end
