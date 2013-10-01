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

  def query_steam(steamid)
    steam_host="api.steampowered.com"
    steam_path="/IPlayerService/GetOwnedGames/v0001/"
    steam_key=@@config_obj['steam_key']
    logger.debug { "key: #{steam_key}" }
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
        logger.debug { "Failed to parse response document #{e}" }
        success = false
        count += 1
      end
    end while !success && count < 5

    unless success
      logger.error { "Failed to connect to steam after n tries, so giving up" }
      return nil
    end
    data
  end

end
