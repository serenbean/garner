module Garner
  module Strategies
    module Binding
      module Key
        class SafeCacheKey < Base
          VALID_FORMAT = /^(?<model>[^\/]+)\/(?<id>.+)-(?<timestamp>[0-9]{14})$/
          RAILS_4_FORMAT = /^(?<model>[^\/]+)\/(?<id>.+)-(?<timestamp>[0-9]{23})$/

          # Compute a cache key from an object binding. Only return a key if
          # :cache_key and :updated_at are both defined and present on the
          # object, and if :cache_key conforms to the ActiveModel format.
          #
          # If all requirements are met, append the millisecond portion of
          # :updated_at to :cache_key.
          #
          # @param binding [Object] The object from which to compute a key.
          # @return [String] A cache key string.
          def self.apply(binding)
            binding = binding.proxy_binding if binding.respond_to?(:proxy_binding)

            return unless binding.respond_to?(:cache_key) && binding.cache_key
            return unless binding.respond_to?(:updated_at) && binding.updated_at

            # Check for ActiveModel cache key format
            if binding.cache_key =~ VALID_FORMAT
              cache_key = binding.cache_key
            else
              return unless binding.cache_key =~ RAILS_4_FORMAT
              cache_key = binding.cache_key[0...-9]
            end

            decimal_portion = binding.updated_at.utc.to_f % 1
            decimal_string = sprintf("%.10f", decimal_portion).gsub(/^0/, "")
            "#{cache_key}#{decimal_string}"
          end

        end
      end
    end
  end
end
