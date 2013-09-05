require 'yaml'

class BadgeOverflowConfig
  attr_reader :config_file

  def self.instance
    @@instance ||= new('config/users.yml')
  end

  def self.user_id
    instance.user_id
  end

  def initialize(config_file)
    @config_file = config_file
  end

  def user_id
    @user_id ||= config['user_id']
    @user_id ||= random_user
  end

  private

  def random_user
    config['users'].sample['id']
  end

  def config
    @@config ||= YAML.load(File.read(config_file))
  end
end
