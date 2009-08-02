require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "PersistentScope" do

  describe "adding one persistent scope" do
    
    before(:each) do
      Blog.add_persistent_scope :published
      @pub_1 = Blog.create!(:title => 'Pub 1', :published => true)
      @pub_2 = Blog.create!(:title => 'Pub 2', :published => true)
      @unpub_1 = Blog.create!(:title => 'Unpub 1', :published => false)
      @unpub_2 = Blog.create!(:title => 'Unpub 2', :published => false)
    end
    
    it "should find a published one" do
      Blog.find(@pub_1.id).should == @pub_1
    end
    
    it "should not find an unpublished one" do
      lambda {
        Blog.find(@unpub_1.id)
      }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
  
  describe "raising an error when" do
    it "add non-existent scope"
  end

end
