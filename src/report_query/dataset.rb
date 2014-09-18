require 'delegate'

module ReportQuery
  class Dataset < SimpleDelegator
    # wrap query methods with this class again because cloning breaks delegation
    Sequel::Dataset::QUERY_METHODS.each do |method_name|
      define_method(method_name) do |*args, &block|
        self.class.new(__getobj__().send(method_name, *args, &block))
      end
    end

    def apply_segment(segment)
      scope = segment.fetch('scope')
      condition = segment['condition']
      self.send("apply_segment_#{scope}", condition)
    end

    def apply_dimension(table_name)
      self.send("apply_dimension_#{table_name}")
    end

    def apply_filters(filters)
      if filters.any?
        where{ |o| Sequel.&(*filters) }
      else
        self
      end
    end

    private

    def apply_segment_public(condition)
      self
    end

    def apply_segment_followeds(condition)
      join(:relationships, { followed_id: :picks__user_id }).
        where(relationships__follower_id: condition.fetch('expression')).
      join(:users, id: :followed_id)
    end

    def apply_dimension_sports
      join(:leagues, id: :league_id).
      join(:sports, id: :sport_id).
      group(:sports__id)
    end

    def apply_dimension_leagues
      join(:leagues, id: :league_id).
        group(:leagues__id)
    end

  end
end
