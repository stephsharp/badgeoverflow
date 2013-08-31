require 'net/http'
require 'json'

class StackExchangeService
  attr_reader :site, :api_version

  def initialize(site = 'stackoverflow', api_version = 2.1)
    @site = site
    @api_version = api_version
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

    page = 1
    fetch_all_pages = params.delete(:fetch_all_pages)
    fetch_all_pages = true if fetch_all_pages.nil?

    items = []

    loop do
      response = get(primary_resource, secondary_resource, params.merge(page: page))
      body = JSON.parse(response.body)

      handle_error_if_required(body)

      response_items = body['items']
      response_items ||= []
      items += response_items

      page += 1

      if fetch_all_pages && body['has_more']
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

    path = "/#{api_version}/#{primary_resource}/"
    path << "#{ids.join(';')}/" unless ids.empty?
    path << "#{secondary_resource}/" if secondary_resource

    final_params = default_params.merge(params)

    stack_exchange.get("#{path}?#{param_string(final_params)}")
  end

  def handle_error_if_required(response_body)
    error_id = response_body['error_id']
    if error_id
      name = response_body['error_name']
      message = response_body['error_message']

      case name
      when "throttle_violation"
        seconds_remaining = message.gsub(/^.*?(\d+) seconds$/, '\1').to_i
        raise "Throttle violation! This will be lifted at #{Time.new + seconds_remaining}."
      else
        raise "#{name} (#{error_id}): #{message}"
      end
    end
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
