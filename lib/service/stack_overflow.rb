require 'net/http'
require 'json'

module Service
  class StackOverflow

    class << self

      # Fetches 1 or more of a given resource.
      #
      # When the request completes, the 'items' key of the response is
      # yielded to the block. If there are multiple results, an array
      # will be yielded, otherwise just the first element of the
      # 'items' array.
      #
      # Params:
      # +resource+::
      #   the stack exchange resource, e.g., "users" or "badges"
      # +ids+::
      #   the remaining parameters are interpreted as an array of ids
      #
      def fetch(resource, *ids) # :yields: item_or_items
        response = get(resource.to_s, ids)
        items = JSON.parse(response.body)['items']

        if block_given?
          if items.nil? or items.length == 0
            yield nil
          else
            yield items.length == 1 ? items.first : items
          end
        end
      end

      private

      def get(resource, *ids)
        stack_exchange.get("/2.1/#{resource}/#{ids.join(';')}?site=stackoverflow")
      end

      def stack_exchange
        Net::HTTP.new('api.stackexchange.com')
      end

    end

  end
end
