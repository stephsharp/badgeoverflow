require 'badgeoverflow/core'
require 'cgi'

service = StackExchangeService.new

# filter '!SmOhH*oSkO4VKR5084' (not working): high_resolution_icon_url, api_site_parameter, name
# filter '!SmOhH.Dupn)h3uctFd': high_resolution_icon_url, icon_url, api_site_parameter, name
service.fetch 'sites', {
  filter: '!SmOhH.Dupn)h3uctFd',
  fetch_all_pages: true
} do |sites|
  site = sites.find { |site|
    site['api_site_parameter'] == service.site
  }

  send_event 'site', {
    name: CGI.unescapeHTML(site['name']),
    icon: site['high_resolution_icon_url']
  }
end
