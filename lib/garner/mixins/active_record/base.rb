require "garner"
require "active_record"

module Garner
  module Mixins
    module ActiveRecord
      module Base
        extend ActiveSupport::Concern
        include Garner::Cache::Binding

        def identity_string
          "#{self.class.name}/id=#{id}"
        end

        included do
          extend Garner::Cache::Binding

          # Return an object that can act as a binding on this class's behalf.
          #
          # @return [ActiveRecord::Base]
          def self.proxy_binding
            _latest_by_updated_at
          end

          def self.identify(handle)
            ActiveRecord::Identity.from_class_and_handle(self, handle)
          end

          # Find an object by id, or other findable field, or by multiple findable
          # fields, first trying to fetch from Garner's cache.
          #
          #
          # @example Find by an id.
          #   Garner::Mixins::ActiveRecord::Base.garnered_find(ObjectId.new)
          #
          # @example Find by multiple id's.
          #   Garner::Mixins::ActiveRecord::Base.garnered_find(ObjectId.new, ObjectId.new)
          #
          # @example Find by multiple id's in an array.
          #   Garner::Mixins::ActiveRecord::Base.garnered_find([ ObjectId.new, ObjectId.new ])
          #
          # @return [ Array<ActiveRecord::Base>, ActiveRecord::Base ]
          def self.garnered_find(*args)
            identity = Garner::Cache::Identity.new
            args.flatten.each do |arg|
              binding = identify(arg)
              identity = identity.bind(binding)
            end
            identity.key({ :garnered_find_args => args }) do
              find(*args)
            end
          end

          after_create    :_garner_after_create
          after_update    :_garner_after_update
          after_destroy   :_garner_after_destroy

          protected
          def self._latest_by_updated_at
            order('updated_at DESC').first
          end

          def _invalidate
            invalidation_strategy.apply(self)
          end

        end
      end
    end
  end
end
