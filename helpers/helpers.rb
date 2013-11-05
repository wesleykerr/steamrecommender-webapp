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

  # retrieve related recommendations for the given appid
  # @param [Number] the appid to lookup
  # @param [Number] the number of recommendations
  # @return [Array] recommended items
  def getRecomms(appids, nrecs)
    headers = Model.get(1, -1)
    headers = headers.model_column.split(",").map { |x| x.to_i } 
    models = Model.all(:model_id => 1, :appid => appids)
    models.collect do |model,idx|
      apps = []
      model.model_column.split(",").each_with_index do |x,idx|
        apps << [headers[idx], x]
      end
      apps.sort! { |x,y| y[1] <=> x[1] }
      apps[0..(nrecs-1)]
    end
  end

  # This method will query the database to see if this steam id has been online
  # recently and therefore there is no need to query steam for their profile since
  # it couldn't have changed much
  # @param [String] steamid
  # @return json game details if they exist in the cache
  def querySteamCache(steamid) 
    min_date = DateTime.now - Rational(8, 24)
    audit_records = Audit.all(:steamid => steamid, 
                              :order => [ :create_datetime.desc ])
    json_obj = nil  
    if (audit_records && audit_records.length > 0 && 
        audit_records.first[:create_datetime] > min_date)
      audit_recomm = audit_records.first
      json_obj = audit_recomm[:json]
    end
    json_obj
  end

  # This method will query the key-value cache for the steamid and if
  # it is prsent will return the details that we've retrieved within the
  # last eight hours.
  # @param [String] steamid
  # @return json details of the game stored in the cache
  def queryProfileCache(steamid)
    min_date = DateTime.now - Rational(8, 24)
    audit_records = AuditProfile.all(:steamid => steamid, 
                                     :order => [ :create_datetime.desc ])
    json_obj = nil  
    if (audit_records && audit_records.length > 0 && 
        audit_records.first[:create_datetime] > min_date)
      audit_recomm = audit_records.first
      json_obj = audit_recomm[:json]
    end
    json_obj
  end

  def getProfile(steamid)
    cacheDetails = queryProfileCache(steamid)
    return cacheDetails if cacheDetails

    # the details are missing so we need to query it
    steamDetails = getSteamDetails(steamid)
    
  end 

  # This method sends a query to steam to get the most recent
  # statistics about a players gaming habits.
  # @param [String] steamid
  def getSteamDetails(steamid)
    json_obj = querySteamCache(steamid)
    return json_obj if json_obj
    
    host="api.steampowered.com"
    path="/IPlayerService/GetOwnedGames/v0001/"
    steam_key=@@config_obj['steam_key']
    params='include_played_free_games=1'
    uri = URI("http://#{host}#{path}?key=#{steam_key}&steamid=#{steamid}&#{params}")
    
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

    data.sort! { |x,y| y['playtime_forever'] <=> x['playtime_forever'] }
    audit = Audit.create(
      :steamid => steamid,
      :json => data,
      :create_datetime => DateTime.now
    )
    logger.error("Failed to create audit record #{steamid}") unless audit.saved?
    data
  end
end
