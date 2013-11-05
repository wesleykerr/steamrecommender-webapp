

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

  # Get the games for the given steam id.  First check to
  # see if we have pulled a profile record for this id
  # recently.  If found, return that otherwise query steam
  # and create the audit record.
  # @param [Number] the steam id to query
  def getGames(steamid)

  end

  # Query steam and pull down the profile information that for a player
  # if it is necessary.
  # @param [Number] the steam id that we are pulling
  def getGamesFromSteam(steamid)
    # TODO: add retry logic
    steam_host="api.steampowered.com"
    steam_path="/IPlayerService/GetOwnedGames/v0001/"
    steam_key=@config_obj['steam_key']
    steam_params='include_played_free_games=1'
    uri = URI("http://#{steam_host}#{steam_path}?key=#{steam_key}&steamid=#{steamid}&#{steam_params}")
    count = 0 
    success = false
    begin
      begin
        document = Net::HTTP.get(uri)
        data = JSON.parse(document)['response']
        success = true
      rescue JSON::ParserError => e
        @log.error { "Failed to parse response document #{e}" }
        success = false
        count += 1
      end
    end while !success && count < 5

    unless success
      @log.error { "Failed to connect to steam after n tries, so giving up" }
      raise IOError, "Steam connection error!" 
    end

    # save an audit record
    audit = Audit.create(
      :steamid => steamid,
      :json => data,
      :create_datetime => DateTime.now
    )
    logger.error("Failed to create audit record #{steamid}") unless audit.saved?
    data
  end
end
