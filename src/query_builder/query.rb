require_relative 'dataset'

module QueryBuilder
  class Query
    def initialize(params)
      @params = params
      # TODO handle nil & empty values
    end

    def dataset
      Dataset.new(DATABASE[:picks]).
        select { |o| dimension_columns(dimension) + metric_columns }.
        apply_dimension(dimension).
        apply_filters(filters_from_params).
        order(order_from_params)
    end

    def print_debug
      ds = dataset
      puts "--------"
      puts ds.sql.to_s
      puts "--------"
      ds.all.each do |row|
        puts row.inspect
      end
      puts "--------"
    end

    private

    def params
      @params
    end

    def metric(function_name, column_name,
               as = "#{function_name}_#{column_name}")
      Sequel::SQL::Function.new(function_name,
          Sequel::SQL::QualifiedIdentifier.new('picks', column_name)).
        as(as)
    end

    def dimension
      params.fetch('dimension')
    end

    def metric_columns
      params.fetch('metrics').map do |metric_params|
        metric(metric_params['agg'], metric_params['column'])
      end
    end

    def dimension_columns(table_name)
      [
        metric('count', 'id', 'total'),
        Sequel::SQL::QualifiedIdentifier.new(table_name, 'id').as('dimension_id'),
        Sequel::SQL::QualifiedIdentifier.new(table_name, 'name').as('dimension_name')
      ]
    end

    def filters_from_params
      return [] unless params.has_key?('filters')

      params.fetch('filters').map do |filter_params|
        { Sequel::SQL::QualifiedIdentifier.new(filter_params['table'],
                                               filter_params['column']).
            sql_string => filter_params['value'] }
      end
    end

    def order_from_params
      sort_params = params.fetch('sort')
      Sequel.send(sort_params['order'], sort_params['column'])
    end
  end
end
