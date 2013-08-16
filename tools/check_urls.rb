
require 'yaml'
require 'models/init.rb'
require 'net/http'
require 'uri'

# find all games that have not been checked and those that
# have not been checked in a long time (1 week)
num_days = 7

games = Game.all(:last_checked => nil) + Game.all(:last_checked.lte => DateTime.now - 7)
puts games.length

games.each do |game|
  puts "Game #{game.appid} : #{game.title}"
  store_url = "http://store.steampowered.com/app/#{game.appid}"
  uri = URI.parse(store_url)
  response = Net::HTTP.get_response(uri)
  game.steam_url = store_url if response.code == "200"
  
  image_url = "http://cdn2.steampowered.com/v/gfx/apps/#{game.appid}/header_292x136.jpg"
  uri = URI.parse(image_url)
  response = Net::HTTP.get_response(uri)
  if response.code == "200"
    game.steam_img_url = image_url 
  else
    game.steam_img_url = "http://www.steamrecommender.com/img/applogo.gif" 
  end
  
  game.last_checked = DateTime.now
  game.save
end

