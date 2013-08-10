user_id = 1164143
avatar_size = 230

SCHEDULER.every '5m', :first_in => 0 do |job|
  include Service

  StackOverflow.fetch 'users', ids: user_id do |user|
    profile_image = user['profile_image']

    if profile_image.include? 'gravatar.com'
      profile_image << "&size=#{avatar_size}"
    end

    send_event 'user', {
      image: profile_image,
      width: avatar_size
    }
  end
end
