module StackExchange

  class Badge
    attr_reader :badge_id, :name, :description, :rank, :award_count, :badge_type, :link

    def initialize(badge_json)
      @data = badge_json
    end

    def badge_id
      @data['badge_id']
    end

    def name
      @data['name']
    end

    def description
      @data['description']
    end

    def rank
      @data['rank']
    end

    def award_count
      @data['award_count']
    end

    def badge_type
      @data['badge_type']
    end

    def link
      @data['link']
    end

    class << self
      alias_method :orig_new, :new

      def new(badge_json)
        badge_class = badge_class_from_name(badge_json['name'])

        if should_instantiate_subclass?(badge_class)
          badge_class.new(badge_json)
        else
          orig_new(badge_json)
        end
      end

      private

      def badge_class_from_name(name)
        if StackExchange.const_defined?(name)
          badge_class = StackExchange.const_get(name)
        else
          nil
        end
      end

      def should_instantiate_subclass?(subclass)
        subclass && self != subclass
      end
    end
  end
end

# load badges
badge_dir = File.join(File.dirname(File.absolute_path(__FILE__)), 'badges')
Dir["#{badge_dir}/*.rb"].each do |badge_file|
  require badge_file
end
