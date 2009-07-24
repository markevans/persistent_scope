require 'active_record'

module PersistentScope
end

ActiveRecord::Base.extend(PersistentScope)