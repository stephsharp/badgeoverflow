badge_dir = File.join(File.dirname(File.absolute_path(__FILE__)), 'badges')
Dir["#{badge_dir}/*.rb"].each do |badge_file|
  require badge_file
end
