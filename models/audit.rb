require 'dm-core'
require 'dm-migrations'

class Audit
  include DataMapper::Resource

  property :id,               Serial, :key => true
  property :steamid,          Integer, :min => 0, :max => 2**64-1
  property :create_datetime,  DateTime, :index => true
  property :json,             Json, :length => 750000

  # This method will query the database to see if this steam id has been online
  # recently and therefore there is no need to query steam for their profile since
  # it couldn't have changed much
  # @param [String] steamid
  # @return json game details if they exist in the cache
  def self.getAuditRecord(steamid)
    min_date = DateTime.now - Rational(8, 24)
    audit_record = Audit.first(:steamid => steamid, 
                               :order => [ :create_datetime.desc ])
    json_obj = nil  
    if (audit_record && audit_record[:create_datetime] > min_date)
      json_obj = audit_record[:json]
    end
    json_obj
  end
end

class AuditProfile
  include DataMapper::Resource

  property :id,               Serial, :key => true
  property :steamid,          Integer, :min => 0, :max => 2**64-1, :index => true
  property :create_datetime,  DateTime, :index => true
  property :profile,          Json, :length => 750000

  # This method will query the key-value cache for the steamid and if
  # it is prsent will return the details that we've retrieved within the
  # last eight hours.
  # @param [String] steamid
  # @return json details of the game stored in the cache
  def self.getAuditRecord(steamid)
    min_date = DateTime.now - Rational(8, 24)
    audit_record = AuditProfile.first(:steamid => steamid, 
                                      :order => [ :create_datetime.desc ])
    json_obj = nil  
    if (audit_record && audit_record[:create_datetime] > min_date)
      json_obj = audit_record[:json]
    end
    json_obj
  end
end

class AuditRecomm
  include DataMapper::Resource

  property :id,               Serial, :key => true
  property :steamid,          Integer, :min => 0, :max => 2**64-1, :index => true
  property :create_datetime,  DateTime, :index => true
  property :recomms,          Json, :length => 750000

  # This method will query the cache for the steamid and if
  # it is present will return the details that we've retrived
  # within the last eight hours
  # @param [String] steamid
  # @return json details of the recommendations in the cache
  def self.getAuditRecord(steamid)
    min_date = DateTime.now - Rational(8, 24)
    audit_record = AuditRecomm.first(:steamid => steamid,
                                     :order => [ :create_datetime.desc ])
    json_obj = nil
    if (audit_record && audit_record[:create_datetime] > min_date)
      json_obj = audit_record[:json]
      logger.info { "Found a record for #{steamid}" }
    end
    json_obj
  end
end

