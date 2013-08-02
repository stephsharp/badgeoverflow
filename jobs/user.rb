require 'net/http'
require 'json'

user_id = 1164143

SCHEDULER.every '1m', :first_in => 0 do |job|
  stack_exchange = Net::HTTP.new('api.stackexchange.com')
  response_body = JSON.parse(stack_exchange.get("/2.1/users/#{user_id}?site=stackoverflow").body)
  user = response_body['items'].first

  send_event 'avatar',
    image: user['profile_image'],
    width: 75
end
