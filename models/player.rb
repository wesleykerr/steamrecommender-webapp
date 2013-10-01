require 'dm-core'
require 'dm-migrations'

class Player 
  include DataMapper::Resource

  property :steamid,          Integer, :min => 0, :max => 2**64-1, :key => true
  property :json_data,        Text
  property :updated_datetime, DateTime

  def self.get_record(steamid)
    # 4 hours back
    s_time = Time.now
    min_date = DateTime.now - Rational(24, 24)
    player_record = Player.get(steamid)
    if player_record && player_record.updated_datetime >= min_date
      return player_record.json_data
    end

    ## request the most recent document from steam
    json_obj = query_steam(steamid)
    return nil unless json_obj

    map = { }
    data['games'].each do |game_stats|
      game_details = {}
      game_details['appid'] = game_stats['appid']
      game_details['playtime_forever'] = game_stats['playtime_forever'] / 60.0
      game_details['playtime_recent'] = game_stats['playtime_2weeks'] / 60.0 if game_stats['playtime_2weeks']
      map[game_stats['appid'] = game_details
    end

    games = Game.all(:fields => [:appid,:title,:steam_url,:steam_img_url], :appid => map.keys)
    games.each do |game|
      game_details = map[game.appid]
      game_details['title'] = game.title
      game_details['steam_url'] = game.steam_url
      game_details['steam_img_url'] = game.steam_img_url
    end

    player = Player.create(:steamid => steamid, :json_data => map.to_json, :updated_datetime => DateTime.now)
    player.json_data
  end
end

