module Garner
  module Mixins
    module ActiveRecord
      class Identity
        include Garner::Cache::Binding

        attr_accessor :klass, :handle, :proxy_binding, :conditions

        # Instantiate a new ActiveRecord::Identity.
        #
        # @param klass [Class] A
        # @param handle [Object] A String, Fixnum, etc.
        #   identifying the object.
        # @return [Garner::Mixins::ActiveRecord::Identity]
        def self.from_class_and_handle(klass, handle)
          validate_class!(klass)

          self.new.tap do |identity|
            identity.klass = klass
            identity.handle = handle
            identity.conditions = conditions_for(klass, handle)
          end
        end

        def initialize
          @conditions = {}
        end

        # Return an object that can act as a binding on this identity's behalf.
        #
        # @return [ActiveRecord::Base]
        def proxy_binding
          return nil unless handle
          @proxy_binding ||= klass.where(conditions).limit(1).first
        end

        # Stringize this identity for purposes of marshaling.
        #
        # @return [String]
        def to_s
          "#{self.class.name}/klass=#{klass},handle=#{handle}"
        end

        private
        def self.validate_class!(klass)
          if !klass.include?(ActiveRecord::Base)
            raise "Must instantiate from a ActiveRecord class"
          end
        end

        def self.conditions_for(klass, handle)
          conditions = { :id => handle }

          conditions
        end
      end
    end
  end
end
