require 'spec'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'persistent_scope'

DB_FILE = File.expand_path(File.dirname(__FILE__)+'/db.sqlite3')
%w{migration models/blog models/post models/comment}.each do |file|
  require "#{File.dirname(__FILE__)}/#{file}"
end 

Spec::Runner.configure do |config|
  
  config.before(:all) do
    FileUtils.rm_f(DB_FILE)
    ActiveRecord::Base.establish_connection(
       :adapter => "sqlite3",
       :database  => DB_FILE
     )
     MigrationForTest.up
  end
  
end
