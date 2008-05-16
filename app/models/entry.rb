class Entry
  include DataMapper::Resource
  include DataMapper::Validate
  include Paperclip
  
  property :id, Fixnum, :serial => true
  has_attached_file :image, :styles => { :thumb => '300x300>' }  
end
