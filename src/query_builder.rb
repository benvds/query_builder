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

  def self.metric(function_name, column_name, as = "#{function_name}_#{column_name}")
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

  def self.metric_columns
    [
      metric('avg', 'odd'),
      metric('sum', 'stake')
    ]
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
    CLONE_METHODS.each do |method_name|
      define_method(method_name) do |*args, &block|
        self.class.new(__getobj__().send(method_name, *args, &block))
      end
    end

    def apply_dimension(table_name)
      self.class.new(self.send("apply_dimension_#{table_name}"))
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

  # sports = DB[:picks].
  #   select { |o| [
  #     o.count(o.picks__id).as('total'),
  #     o.sports__id.as('dimension_id'),
  #     o.sports__name.as('dimension_name'),
  #     metric('avg', 'odd'),
  #     metric('sum', 'stake')
  #   ]}.
  #   join(:leagues, id: :league_id).
  #   join(:sports, id: :sport_id).
  #   group(:sports__id)

  # print_result_set(sports)

  sports = ReportDataset.new(DB[:picks]).
    select { |o| dimension_columns('sports') + metric_columns }.
    apply_dimension('sports')

  print_result_set(sports)

  leagues = ReportDataset.new(DB[:picks]).
    select { |o| dimension_columns('leagues') + metric_columns }.
    apply_dimension('leagues')

  print_result_set(leagues)

  # params = {
  #   dimension: 'sports',
  #   metrics: [
  #     { agg: 'avg', column: 'odd' },
  #     { agg: 'sum', column: 'stake' }
  #   ]
  # }

end
