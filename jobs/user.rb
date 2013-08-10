user_id = 1164143

SCHEDULER.every '5m', :first_in => 0 do |job|
  include Service

  StackOverflow.fetch :users, user_id do |user|
    send_event 'user', {
      image: user['profile_image'],
      width: 75
    }
  end
end
