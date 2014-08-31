require 'dm-core'
require 'dm-migrations'

class ModelStatus
  include DataMapper::Resource
 
  storage_names[:default] = 'model_status'

  property :model_id,     Integer, :key => true
  property :start_date,   DateTime
  property :end_date,     DateTime

  def self.getModelId()
    model_record = ModelStatus.first(:end_date => nil, 
                                     :order => [:model_id.desc])
    return model_record[:model_id] if model_record
    return 1;
  end
end
