user_id = 1367622
avatar_size = 230

SCHEDULER.every '5m', :first_in => 0 do |job|
  include StackExchange::Service

  StackOverflow.fetch 'users', ids: user_id do |user|
    profile_image = user['profile_image']

    if profile_image.include? 'gravatar.com'
      profile_image << "&size=#{avatar_size}"
    end

    badge_counts = user['badge_counts'].map { |r,c| { rank: r, count: c } }

    send_event 'user', {
      name: user['display_name'],
      link: user['link'],
      reputation: with_suffix(user['reputation']),
      badge_counts: badge_counts,
      image: profile_image,
      width: avatar_size
    }
  end
end

def with_suffix (count)
  suffix = ["k", "m"]
  if (count < 1000)
    count.to_s
  else
    exp = (Math.log(count) / Math.log(1000)).to_i
    "%.1f%c" % [(count.to_f / 1000 ** exp).round(1), suffix[exp-1]]
  end
end
