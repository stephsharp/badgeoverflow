require 'badgeoverflow/core'
require 'cgi'

service = StackExchangeService.new

# filter: high_resolution_icon_url, icon_url, api_site_parameter, name
service.fetch 'sites', {
  filter: '!SmOhH.Dupn)h3uctFd',
  fetch_all_pages: true
} do |sites|
  site = sites.find { |site|
    site['api_site_parameter'] == service.site
  }

  # high_resolution_icon_url may be absent
  icon_url = site['high_resolution_icon_url'] || site['icon_url']

  send_event 'site', {
    name: CGI.unescapeHTML(site['name']),
    icon: icon_url
  }
end
