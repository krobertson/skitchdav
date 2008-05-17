class Entry
  include DataMapper::Resource
  include Paperclip::Resource
  
  property :id, Integer, :serial => true
  property :created_at, DateTime
  has_attached_file :image, :styles => { :thumb => '300x300>', :square => '100x100#' }
  property :image_dimensions, String
  
  before :save, :before_save

  def before_save
    self.created_at = DateTime.now if self.new_record?
    self.image_dimensions = self.image.styles[:thumb][0] if self.new_record? and self.image_dimensions.nil?
  end

  def image_dimensions=(val)
    attribute_set(:image_dimensions, val)
    self.image.styles[:thumb][0] = val unless self.image.nil?
  end
end
