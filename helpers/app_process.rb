require 'logger'
require 'json'
require_relative 'gr_mysql'
require_relative 'game-linker'


def update_steam_games()
  log = Logger.new(STDOUT)
  log.level = Logger::DEBUG

  linker = GameLinker.new
  db = Database.new("localhost", "root")

  api_url = 'http://api.steampowered.com'
  uri = URI("#{api_url}/ISteamApps/GetAppList/v0002/")
  document = Net::HTTP.get(uri)
  apps = JSON.parse(document)["applist"]["apps"]
  buffer = []
  apps.each do |app_hash|
    appid = app_hash["appid"]
    days_old = linker.days_since_updated(appid)
    if days_old > 10
      log.debug { "Appid #{appid} Days: #{days_old}" }
      buffer << appid
      if buffer.size == 10
        linker.get_app_details(buffer)
        buffer.clear
        sleep 5
      end
    end
  end
  linker.get_app_details(buffer)
  buffer.clear
end

update_steam_games

