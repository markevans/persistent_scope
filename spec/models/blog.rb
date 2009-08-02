class Blog < ActiveRecord::Base
  has_many :posts
  has_many :comments, :through => :posts
  
  named_scope :published, :conditions => {:published => true}
  
end