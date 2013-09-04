require 'net/http'
require 'json'

# Steph Sharp: 1367622 
# Adam Sharp: 1164143
# David Underwood: 131066
# Daniel Beauchamp: 208314
# Edward Ocampo-Gooding: 95705
# Jeff Atwood: 1
user_id = 131066

# Get timeline for user - /users/{ids}/timeline 
SCHEDULER.every '1h', :first_in => '2m' do |job|
  stack_exchange = Net::HTTP.new('api.stackexchange.com')
  last_badge = nil;
  page_number = 1
  
  loop do
    user_timeline_response = JSON.parse(stack_exchange.get("/2.1/users/#{user_id}/timeline?page=#{page_number}&pagesize=100&site=stackoverflow").body)

    # Get first badge in timeline
    last_badge = user_timeline_response['items'].find do |item|
      item['timeline_type'] == "badge"
    end
  
    page_number += 1
    backoff = user_timeline_response['backoff']
    
    if backoff
      sleep backoff
    end

    # break loop unless last_badge is nil and there are more pages to search
    break unless (user_timeline_response['has_more'] && last_badge.nil?)
  end  

  # Check if user has no badges
  unless last_badge
    send_event('time_since_last_badge', { :text => "No Badges", 
                                          :moreinfo => ""
                                        })
  else
    # Display time since last badge was awarded
    now = Time.now
    last_badge_creation_date = Time.at(last_badge['creation_date'])
    seconds_since_last_badge = now - last_badge_creation_date

    mm, ss = seconds_since_last_badge.divmod(60)
    hh, mm = mm.divmod(60)
    dd, hh = hh.divmod(24)
    time_since_last_badge = "<span class=\"number\">%d</span>d&nbsp;&nbsp;&nbsp;<span class=\"number\">%d</span>h" % [dd, hh]

    send_event('time_since_last_badge', { :text => time_since_last_badge,
                                          :moreinfo => last_badge['detail']
                                        })
  end
end
