source 'https://rubygems.org'

ruby_version = File.read('.ruby-version').split('-').first
ruby "#{ruby_version}"

gem 'dashing'
gem 'badgeoverflow-core', :path => 'badgeoverflow-core'

group :test do
  gem 'rspec'
  gem 'webmock'
end
