require 'bundler/setup'
Bundler.require(:default, :development)

require 'date'
require 'delegate'

module QueryBuilder
  DB_FILE = 'tmp/query_builder.db'

  if File.exists? DB_FILE
    DB = Sequel.sqlite(DB_FILE)
  else
    File.new(DB_FILE, 'w+')
    DB = Sequel.sqlite(DB_FILE)

    require_relative 'query_builder/create_schema'
    require_relative 'query_builder/seed'

    QueryBuilder::CreateSchema.run(DB)
    QueryBuilder::SeedDB.run(DB)
  end

  def self.print_result_set(result_set)
    puts ""
    puts result_set.sql.to_s
    puts ""

    result_set.each do |row|
      puts row.inspect
    end

    puts ""
  end

  def self.metric(function_name, column_name,
                  as = "#{function_name}_#{column_name}")
    Sequel::SQL::Function.new(function_name,
        Sequel::SQL::QualifiedIdentifier.new('picks', column_name)).
      as(as)
  end

  def self.dimension_columns(table_name)
    [
      metric('count', 'id', 'total'),
      Sequel::SQL::QualifiedIdentifier.new(table_name, 'id').as('dimension_id'),
      Sequel::SQL::QualifiedIdentifier.new(table_name, 'name').as('dimension_name')
    ]
  end

  def self.metric_columns_from_params(query_params)
    query_params['metrics'].map do |metric_params|
      metric(metric_params['agg'], metric_params['column'])
    end
  end

  def self.filters_from_params(query_params)
    return [] unless query_params.has_key?('filters')

    query_params.fetch('filters').map do |filter_params|
      { Sequel::SQL::QualifiedIdentifier.new(filter_params['table'],
                                             filter_params['column']).
          sql_string => filter_params['value'] }
    end
  end

  def self.order_from_params(query_params)
    sort_params = query_params['sort']
    Sequel.send(sort_params['order'], sort_params['column'])
  end

  def self.report_query(query_params)
    dimension = query_params['dimension']
    metric_columns = metric_columns_from_params(query_params)

    ReportDataset.new(DB[:picks]).
      select { |o| dimension_columns(dimension) +
               metric_columns }.
      apply_dimension(dimension).
      apply_filters(filters_from_params(query_params)).
      order(order_from_params(query_params))
  end

  class ReportDataset < SimpleDelegator

    # Dataset methods calling internal clone method
    CLONE_METHODS = %w(
      distinct except from from_self group_cube group_rollup intersect
      invert join_table lateral limit lock_style offset or order
      qualify returning select select_all server unbind unfiltered ungrouped
      union unlimited with with_recursive with_sql compound_clone
    )

    # wrap clone methods with this class again because cloning breaks delegation
    # CLONE_METHODS.each do |method_name|
    Sequel::Dataset::QUERY_METHODS.each do |method_name|
      define_method(method_name) do |*args, &block|
        self.class.new(__getobj__().send(method_name, *args, &block))
      end
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

  query_params = {
    'dimension' => 'sports',
    'metrics' => [
      { 'agg' => 'avg', 'column' => 'odd' },
      { 'agg' => 'sum', 'column' => 'stake' }
    ],
    'filters' => [
      {
        'table' => 'sports',
        'column' => 'id',
        'value' => '1' # soccer
      }
    ],
    'sort' => {
      'column' => 'dimension_name',
      'order' => 'asc'
    }
  }

  print_result_set(report_query(query_params))

end
