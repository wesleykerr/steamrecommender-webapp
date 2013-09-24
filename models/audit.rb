require 'dm-core'
require 'dm-migrations'

class Audit
  include DataMapper::Resource

  property :id,               Serial, :key => true
  property :steamid,          Integer, :min => 0, :max => 2**64-1
  property :create_datetime,  DateTime, :index => true
  property :json,             Json
end

class AuditRecomm
  include DataMapper::Resource

  property :id,               Serial, :key => true
  property :steamid,          Integer, :min => 0, :max => 2**64-1, :index => true
  property :create_datetime,  DateTime, :index => true
  property :recomms,          Json
end

