require 'net/http'
require 'json'

class StackExchangeService
  attr_reader :site

  def initialize(site = 'stackoverflow')
    @site = site
  end

  # Fetches 1 or more of a given resource.
  #
  # When the request completes, the 'items' key of the response is
  # yielded to the block. If there are multiple results, an array
  # will be yielded, otherwise just the first element of the
  # 'items' array.
  #
  # Params:
  # +primary_resource+::
  #   the stack exchange resource, e.g., "users", "badges/name"
  # +secondary_resource+::
  #   an optional nested resource, e.g., "users/1/badges"
  # +params+::
  #   an optional params hash; all passed through to the query
  #   string, except for the special param +:ids+ which is an
  #   array of ids passed into the URL path
  #
  def fetch(primary_resource, secondary_resource = nil, params = {}) # :yields: item_or_items
    if secondary_resource.kind_of? Hash
      params = secondary_resource
      secondary_resource = nil
    end

    items = []
    page = 1

    loop do
      response = get(primary_resource, secondary_resource, params.merge(page: page))
      body = JSON.parse(response.body)

      response_items = body['items']
      response_items ||= []
      items += response_items

      page += 1

      if body['has_more']
        backoff = body['backoff']
        if backoff
          sleep backoff
        end
      else
        break
      end
    end

    result = items.length == 1 ? items.first : items

    if block_given?
      yield result
    end

    result
  end

  private

  def get(primary_resource, secondary_resource, params = {})
    ids = *params.delete(:ids)

    path = "/2.1/#{primary_resource}/"
    path << "#{ids.join(';')}/" unless ids.empty?
    path << "#{secondary_resource}/" if secondary_resource

    final_params = default_params.merge(params)

    stack_exchange.get("#{path}?#{param_string(final_params)}")
  end

  def stack_exchange
    @stack_exchange ||= Net::HTTP.new('api.stackexchange.com')
  end

  def default_params
    { site: site, pagesize: 30 }
  end

  def param_string(params)
    params.map{|k,v| "#{k}=#{v}"}.join('&')
  end

end
