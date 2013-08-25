module StackExchange

  class Badge
    attr_reader :badge_id, :user_id, :name, :description, :rank, :award_count, :badge_type, :link

    def initialize(badge_json, user_id)
      @data = badge_json
      @user_id = user_id
    end

    def progress
      description
    end

    def badge_id;    @data['badge_id'];    end
    def name;        @data['name'];        end
    def description; @data['description']; end
    def rank;        @data['rank'];        end
    def award_count; @data['award_count']; end
    def badge_type;  @data['badge_type'];  end
    def link;        @data['link'];        end

    class << self
      alias_method :orig_new, :new

      def new(badge_json, *args)
        badge_class = badge_class_from_name(badge_json['name'])

        if should_instantiate_subclass?(badge_class)
          badge_class.new(badge_json, *args)
        else
          orig_new(badge_json, *args)
        end
      end

      private

      def badge_class_from_name(name)
        constant_name = constantise(name)

        if StackExchange.const_defined?(constant_name)
          badge_class = StackExchange.const_get(constant_name)

          if badge_class.ancestors.include?(Badge)
            badge_class
          end
        end
      end

      def should_instantiate_subclass?(subclass)
        subclass && self != subclass
      end

      def constantise(badge_name)
        badge_name.gsub(/[\W]/, '')
      end
    end
  end
end

# load badges
badge_dir = File.join(File.dirname(File.absolute_path(__FILE__)), 'badges')
Dir["#{badge_dir}/*.rb"].each do |badge_file|
  require badge_file
end
