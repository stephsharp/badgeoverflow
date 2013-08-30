user_id = 1367622
avatar_size = 230

service = StackExchangeService.new

SCHEDULER.every '5m', :first_in => 0 do |job|
  service.fetch 'users', ids: user_id do |user|
    profile_image = user['profile_image']

    if profile_image.include? 'gravatar.com'
      profile_image << "&size=#{avatar_size}"
    end

    badge_counts = user['badge_counts'].map { |r,c| { rank: r, count: c } }

    send_event 'user', {
      name: user['display_name'],
      link: user['link'],
      reputation: user['reputation'].with_suffix,
      badge_counts: badge_counts,
      image: profile_image,
      width: avatar_size
    }
  end
end
