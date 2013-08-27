require 'net/http'
require 'json'

module StackExchange
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
        def fetch(resource, params = {}) # :yields: item_or_items
          items = []
          page = 1

          loop do
            response = get(resource.to_s, params.merge(page: page))
            body = JSON.parse(response.body)

            response_items = body['items']
            response_items ||= []
            items += response_items

            page += 1

            break unless body['has_more']
          end

          if block_given?
            if items.empty?
              yield nil
            else
              yield items.length == 1 ? items.first : items
            end
          end
        end

        private

        def get(resource, params = {})
          ids = *params.delete(:ids)
          final_params = default_params.merge(params)
          stack_exchange.get("/2.1/#{resource}/#{ids.join(';')}?#{param_string(final_params)}")
        end

        def stack_exchange
          Net::HTTP.new('api.stackexchange.com')
        end

        def default_params
          { site: 'stackoverflow', pagesize: 30 }
        end

        def param_string(params)
          params.map{|k,v| "#{k}=#{v}"}.join('&')
        end

      end

    end
  end
end
