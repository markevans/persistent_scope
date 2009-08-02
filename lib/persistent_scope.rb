require 'active_record'

module ActiveRecord
  class Base

    class << self

      def add_persistent_scope (scope_name)
        # self.persistent_scoping = [if persistent_scoping.empty?
        #   scopes[scope_name]
        # else
        #   with_scope(persistent_scoping){ scopes[scope_name] }
        # end]
      end
      
      protected
      
      def persistent_scoping
        # Form the 'persistent scoping out of the default
        # scoping and all the currently active persistent
        # scopes
        # TODO: use merge_scopings HERE!!!!
        default_scoping
      end
          
      # Almost the same as activerecord code -
      # just swapped 'default_scoping' for 'persistent_scoping'
      def scoped_methods #:nodoc:
        Thread.current[:"#{self}_scoped_methods"] ||= self.persistent_scoping.dup
      end

      # This is kind of annoying that I need to do this, but split up the
      # original with_scope method into chunks so I can use those
      # chunks elsewhere
      def with_scope(method_scoping = {}, action = :merge, &block)
        method_scoping = method_scoping.method_scoping if method_scoping.respond_to?(:method_scoping)

        # Dup first and second level of hash (method and params).
        method_scoping = method_scoping.inject({}) do |hash, (method, params)|
          hash[method] = (params == true) ? params : params.dup
          hash
        end

        method_scoping.assert_valid_keys([ :find, :create ])

        if f = method_scoping[:find]
          f.assert_valid_keys(VALID_FIND_OPTIONS)
          set_readonly_option! f
        end

        self.scoped_methods << merge_scopings(current_scoped_methods, method_scoping, action)
        begin
          yield
        ensure
          self.scoped_methods.pop
        end
      end

      def merge_scopings(scoping1, scoping2, action = :merge)
        if [:merge, :reverse_merge].include?(action) && scoping1
          return scoping1.inject(scoping2) do |hash, (method, params)|
            case hash[method]
              when Hash
                if method == :find
                  (hash[method].keys + params.keys).uniq.each do |key|
                    merge = hash[method][key] && params[key] # merge if both scopes have the same key
                    if key == :conditions && merge
                      if params[key].is_a?(Hash) && hash[method][key].is_a?(Hash)
                        hash[method][key] = merge_conditions(hash[method][key].deep_merge(params[key]))
                      else
                        hash[method][key] = merge_conditions(params[key], hash[method][key])
                      end
                    elsif key == :include && merge
                      hash[method][key] = merge_includes(hash[method][key], params[key]).uniq
                    elsif key == :joins && merge
                      hash[method][key] = merge_joins(params[key], hash[method][key])
                    else
                      hash[method][key] = hash[method][key] || params[key]
                    end
                  end
                else
                  if action == :reverse_merge
                    hash[method] = hash[method].merge(params)
                  else
                    hash[method] = params.merge(hash[method])
                  end
                end
              else
                hash[method] = params
            end
            hash
          end
        end
      end

    end
  end
end
