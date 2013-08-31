class Badge
  include Comparable
  RANK_INDEX = { "bronze" => 0, "silver" => 1, "gold" => 2 }

  attr_reader :badge_id, :user_id, :name, :description, :rank, :award_count, :badge_type, :link
  attr_reader :series, :service

  def initialize(badge_json, user_id)
    @data = badge_json
    @user_id = user_id
  end

  def <=>(other_badge)
    if other_badge.kind_of? Badge
      RANK_INDEX[self.rank] <=> RANK_INDEX[other_badge.rank]
    end
  end

  def ==(other_badge)
    self.eql?(other_badge)
  end

  def progress_description
    description
  end

  def progress_title
    "Have you considered..."
  end

  def series
    @series ||= @@series[self.class]
  end

  def service
    @service ||= StackExchangeService.new('stackoverflow')
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

    def series(name)
      raise "series name must be a symbol" unless name.kind_of?(Symbol)
      @@series[self] = name
    end

    private

    def badge_class_from_name(name)
      constant_name = constantise(name)

      if const_defined?(constant_name)
        badge_class = const_get(constant_name)

        if badge_class.ancestors.include?(Badge)
          badge_class
        end
      end
    end

    def should_instantiate_subclass?(subclass)
      subclass && self != subclass
    end

    def constantise(badge_name)
      badge_name.split(/[\W]/).map(&:capitalize).join
    end
  end

  @@series = {}
end
