class Settings
  include DataMapper::Resource
  storage_names[:default] = 'settings'

  property :id, Integer, :serial => true
  property :dimensions, String, :default => "300x300>"
  property :username, String, :default => 'ken'
  property :password, String, :default => 'test'

  def self.instance
    @settings ||= first
    @settings ||= self.create
  end
  
  def self.update_dimensions(dimensions)
    self.instance
    @settings.dimensions = dimensions
    Entry.attachment_definitions[:image][:styles][:thumb] = dimensions
    @settings.save
  end
end
