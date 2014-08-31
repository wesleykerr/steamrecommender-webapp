require 'rubygems'
require 'bundler/setup'
Bundler.require

require File.expand_path 'app.rb'

run Sinatra::Application
